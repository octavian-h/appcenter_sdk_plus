import 'dart:io';

import '../appcenter_exception.dart';
import '../appcenter_sdk_plus.dart';
import '../domain/managed_error_log.dart';

class AppCenterCrashes {
  static const String _pluginName = "crashes";

  /// Track a handled error with name and optional properties.
  /// The property names and values are limited to 64 characters each.
  /// The number of properties per crash is limited to 5.
  /// The property names or values cannot be null.
  static Future<void> trackError(
    dynamic exception,
    StackTrace? stack, {
    Map<String, String> properties = const {},
    bool fatal = false,
  }) async {
    _validateArgs(properties);

    stack ??= StackTrace.current;
    var convertedException = ExceptionLog(
      type: exception.runtimeType.toString(),
      message: exception.toString(),
      stackTrace: stack.toString(),
    );

    return await AppCenter.instance.logService.addLog(
      ManagedErrorLog(
        appLaunchTimestamp: AppCenter.instance.appLaunchTimestamp,
        sid: AppCenter.instance.sessionId,
        device: AppCenter.instance.deviceService.device,
        properties: properties,
        processId: pid,
        processName: pid.toString(),
        fatal: fatal,
        exception: convertedException,
      ),
    );
  }

  static void _validateArgs(Map<String, String> properties) {
    if (properties.length > 5) {
      throw AppCenterException(
        plugin: _pluginName,
        message:
            "There are more than 5 properties, length=${properties.length}",
        code: "limit_exceeded",
      );
    }

    for (var entry in properties.entries) {
      if (entry.key.isEmpty) {
        throw const AppCenterException(
          plugin: _pluginName,
          message: "Property name cannot be empty",
          code: "empty",
        );
      }
      if (entry.key.length > 64) {
        throw AppCenterException(
          plugin: _pluginName,
          message: "Property name is longer than 64 chars, key=${entry.key}",
          code: "limit_exceeded",
        );
      }
      if (entry.value.length > 64) {
        throw AppCenterException(
          plugin: _pluginName,
          message:
              "Property value is longer than 64 chars, value=${entry.value}",
          code: "limit_exceeded",
        );
      }
    }
  }
}
