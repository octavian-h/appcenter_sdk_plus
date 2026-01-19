import '../appcenter_exception.dart';
import '../appcenter_sdk_plus.dart';
import '../domain/event_log.dart';

class AppCenterAnalytics {
  static const List<String> _reservedPropertyNames = [
    "baseData",
    "baseDataType",
  ];
  static const String _pluginName = "analytics";

  /// Track a custom event with name and optional string properties.
  /// The event name cannot be longer than 256.
  /// The property names and values are limited to 125 characters each.
  /// The number of properties per event is limited to 20.
  /// The property names or values cannot be null.
  /// The baseData and baseDataType properties are reserved.
  static Future<void> trackEvent(
    String eventName, {
    Map<String, String> properties = const {},
  }) async {
    _validateArgs(eventName, properties);

    return await AppCenter.instance.logService.addLog(
      EventLog(
        appLaunchTimestamp: AppCenter.instance.appLaunchTimestamp,
        sid: AppCenter.instance.sessionId,
        device: AppCenter.instance.deviceService.device,
        properties: properties,
        name: eventName,
      ),
    );
  }

  static void _validateArgs(String eventName, Map<String, String> properties) {
    if (eventName.isEmpty) {
      throw const AppCenterException(
        plugin: _pluginName,
        message: "Event name cannot be empty",
        code: "empty",
      );
    }
    if (eventName.length > 256) {
      throw AppCenterException(
        plugin: _pluginName,
        message: "Event name is longer than 256 chars, name=$eventName",
        code: "limit_exceeded",
      );
    }
    if (properties.length > 20) {
      throw AppCenterException(
        plugin: _pluginName,
        message:
            "There are more than 20 properties, length=${properties.length}",
        code: "limit_exceeded",
      );
    }

    for (var entry in properties.entries) {
      if (_reservedPropertyNames.contains(entry.key)) {
        throw AppCenterException(
          plugin: _pluginName,
          message: "Property name is a reserved name, name=${entry.key}",
          code: "reserved",
        );
      }
      if (entry.key.isEmpty) {
        throw const AppCenterException(
          plugin: _pluginName,
          message: "Property name cannot be empty",
          code: "empty",
        );
      }
      if (entry.key.length > 125) {
        throw AppCenterException(
          plugin: _pluginName,
          message: "Property name is longer than 125 chars, name=${entry.key}",
          code: "limit_exceeded",
        );
      }
      if (entry.value.length > 125) {
        throw AppCenterException(
          plugin: _pluginName,
          message:
              "Property value is longer than 125 chars, value=${entry.value}",
          code: "limit_exceeded",
        );
      }
    }
  }
}
