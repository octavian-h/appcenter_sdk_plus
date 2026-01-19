import 'package:logging/logging.dart';

import '../domain/appcenter_options.dart';
import '../domain/log.dart';
import '../infrastructure/appcenter/appcenter_client.dart';
import '../infrastructure/appcenter/http_exception.dart';
import '../infrastructure/persistence/log_repository.dart';

/// Used internally by [AppCenterAnalytics] and [AppCenterCrashes] to send logs.
/// The logs are first written to device storage and when the preconditions are
/// met they are sent to AppCenter server.
class LogService {
  static final Logger _log = Logger((LogService).toString());
  final LogRepository _logRepository;
  final AppCenterClient _client;
  final int _batchSize;
  final Duration _minDelayBetweenRequests;
  DateTime? _lastSendingTime;

  LogService._internal(
    this._logRepository,
    this._client,
    this._batchSize,
    this._minDelayBetweenRequests,
  );

  static Future<LogService> create(
    LogRepository logRepository,
    AppCenterClient client,
    AppCenterOptions options,
  ) async {
    var logService = LogService._internal(
      logRepository,
      client,
      options.logsBatchSize,
      options.minDelayBetweenRequests,
    );
    await logService._sendCachedLogs();
    return logService;
  }

  Future<void> addLog(Log logItem) async {
    await _logRepository.save(logItem);
    await _sendCachedLogs();
  }

  Future<void> _sendCachedLogs() async {
    var now = DateTime.now().toUtc();
    if (_lastSendingTime != null &&
        now.difference(_lastSendingTime!) <= _minDelayBetweenRequests) {
      return;
    }

    var totalLogs = await _logRepository.count();
    if (totalLogs == 0) {
      return;
    }

    _log.fine("Send cached logs, count=$totalLogs");
    int processedLogs = 0;
    bool success;
    do {
      success = false;
      var logs = await _logRepository.findAll(0, _batchSize);
      _lastSendingTime = now;
      try {
        await _client.sendLogs(logs);
        var clearLogsCount = await _clearSentLogs(logs);
        success = clearLogsCount == logs.length;
        processedLogs += clearLogsCount;
      } on HttpException catch (e) {
        if (e.statusCode < 500 && e.statusCode != 408 && e.statusCode != 429) {
          _log.warning(
            "Logs will not be re-send because of invalid api key or invalid data",
            e,
          );
          await _clearSentLogs(logs);
        } else {
          _log.warning("Logs will be re-send", e);
        }
      }
    } while (success && processedLogs < totalLogs);
  }

  Future<int> _clearSentLogs(List<Log> logs) async {
    var logIds = logs.map((item) => item.id).toList();
    await _logRepository.deleteByIds(logIds);
    return logIds.length;
  }
}
