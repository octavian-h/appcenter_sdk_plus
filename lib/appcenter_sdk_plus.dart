library;

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'appcenter_exception.dart';
import 'domain/appcenter_options.dart';
import 'infrastructure/appcenter/appcenter_client.dart';
import 'infrastructure/persistence/log_repository.dart';
import 'infrastructure/platform/physical_device_service.dart';
import 'service/device_service.dart';
import 'service/log_service.dart';
import 'service/simple_device_service.dart';

class AppCenter {
  static final Logger _log = Logger((AppCenter).toString());
  static const String _installIdKey = "appcenter_install_id";
  final String appLaunchTimestamp;
  final String sessionId;
  final LogService logService;
  final DeviceService deviceService;
  static AppCenter? _instance;

  AppCenter._internal(
    this.appLaunchTimestamp,
    this.sessionId,
    this.logService,
    this.deviceService,
  );

  /// Configure the SDK with an app secret parameter.
  /// This may be called only once per application process lifetime.
  static Future<AppCenter> start(
    String appSecret, {
    AppCenterOptions options = const AppCenterOptions(),
  }) async {
    _log.fine("Init AppCenter with options=$options");
    var logRepository = await LogRepository.create(options.logsDbPath);
    var installId = options.installId ?? await _readInstallIdFromSettings();
    var client = AppCenterClient(appSecret, installId, options.sendLogsTimeout);
    var logService = await LogService.create(logRepository, client, options);
    var appLaunchTimestamp = DateTime.now().toIso8601String();
    var sessionId = const Uuid().v1();
    var deviceService = options.device != null
        ? SimpleDeviceService(options.device!)
        : await PhysicalDeviceService.create();

    _instance = AppCenter._internal(
      appLaunchTimestamp,
      sessionId,
      logService,
      deviceService,
    );
    return _instance!;
  }

  static Future<String> _readInstallIdFromSettings() async {
    _log.fine("Read installId from settings");
    var sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(_installIdKey)) {
      return sharedPreferences.getString(_installIdKey) ?? const Uuid().v1();
    }

    var randomId = const Uuid().v1();
    sharedPreferences.setString(_installIdKey, randomId);
    return randomId;
  }

  static AppCenter get instance {
    if (_instance == null) {
      throw const AppCenterException(
        plugin: "core",
        message: "AppCenter was not started - call AppCenter.start(...)",
        code: "not_init",
      );
    }
    return _instance!;
  }
}
