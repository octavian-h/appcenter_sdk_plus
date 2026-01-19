import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'device.dart';

/// The Log model.
@immutable
abstract class Log {
  /// Unique identifier for this log.
  final String id;

  /// The type of the log.
  final String type;

  /// Log timestamp.
  final String timestamp;

  /// Timestamp when the app was launched.
  final String appLaunchTimestamp;

  /// The session identifier that was provided when the session was started.
  final String sid;

  /// Device characteristics associated to this log.
  final Device device;

  /// Additional key/value pair parameters.
  final Map<String, String> properties;

  Log({
    String? id,
    required this.type,
    String? timestamp,
    required this.appLaunchTimestamp,
    required this.sid,
    required this.device,
    required this.properties,
  }) : id = id ?? const Uuid().v1(),
       timestamp = timestamp ?? DateTime.now().toIso8601String();

  Log.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      type = map['type'],
      timestamp = map['timestamp'],
      appLaunchTimestamp = map['appLaunchTimestamp'],
      sid = map['sid'],
      device = Device.fromMap(map['device']),
      properties = _convertToStringMap(map['properties']);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'timestamp': timestamp,
      'appLaunchTimestamp': appLaunchTimestamp,
      'sid': sid,
      'device': device.toMap(),
      'properties': properties,
    };
  }

  static Map<String, String> _convertToStringMap(
    Map<String, dynamic> dynamicMap,
  ) {
    return dynamicMap.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  String toString() {
    return 'Log${toMap()}';
  }
}
