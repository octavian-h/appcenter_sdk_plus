import 'package:flutter/foundation.dart';

import 'log.dart';

/// Event log.
@immutable
class EventLog extends Log {
  /// The name of the event
  final String name;

  EventLog({
    required super.appLaunchTimestamp,
    required super.sid,
    required super.device,
    required super.properties,
    required this.name,
  }) : super(type: "event");

  EventLog.fromMap(super.map) : name = map['name'], super.fromMap();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({'name': name});
    return map;
  }

  @override
  String toString() {
    return 'EventLog${toMap()}';
  }
}
