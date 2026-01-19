import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../domain/log.dart';
import '../../util/constants.dart';
import 'http_exception.dart';
import 'send_logs_response.dart';

class AppCenterClient {
  static final Logger _log = Logger((AppCenterClient).toString());
  final String _appSecret;
  final String _installId;
  final Duration _sendTimeout;

  AppCenterClient(this._appSecret, this._installId, this._sendTimeout);

  /// Used to send logs to AppCenter server
  Future<SendLogsResponse> sendLogs(List<Log> logs) async {
    _log.fine("Sending logs to AppCenter: logs=$logs");
    var listWithMaps = logs.map((e) => e.toMap()).toList();
    http.Response response;
    try {
      var requestBody = jsonEncode({"logs": listWithMaps});
      response = await http
          .post(_buildUrl(), headers: _buildHeaders(), body: requestBody)
          .timeout(_sendTimeout);
    } on TimeoutException catch (e, s) {
      _log.warning("Timeout at sending logs to AppCenter", e, s);
      throw const HttpException(statusCode: 408, message: "Connection timeout");
    } catch (e, s) {
      _log.severe("Failed to send logs to AppCenter", e, s);
      throw HttpException(
        statusCode: 500,
        message: e.toString(),
        stackTrace: s,
      );
    }

    var statusCode = response.statusCode;
    var responseBody = response.body.toString();
    if (statusCode >= 200 && statusCode < 300) {
      _log.fine("Response from AppCenter: $responseBody");
      return SendLogsResponse.fromMap(json.decode(responseBody));
    }
    _log.severe(
      "Failed to send logs to AppCenter. code=$statusCode",
      responseBody,
    );
    throw HttpException(statusCode: statusCode, message: responseBody);
  }

  Uri _buildUrl() =>
      Uri.https("in.appcenter.ms", "logs", {"api-version": "1.0.0"});

  Map<String, String> _buildHeaders() {
    return {
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      "App-Secret": _appSecret,
      "Install-ID": _installId,
      HttpHeaders.userAgentHeader:
          "${Constants.packageName}/${Constants.packageVersion}",
    };
  }
}
