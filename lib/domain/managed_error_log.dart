import 'package:flutter/foundation.dart';

import 'log.dart';

/// Error log for managed platforms.
@immutable
class ManagedErrorLog extends Log {
  /// Process identifier.
  final int processId;

  /// Process name.
  final String processName;

  /// If true, this crash report is an application crash.
  final bool fatal;

  /// Exception.
  final ExceptionLog exception;

  ManagedErrorLog({
    required super.appLaunchTimestamp,
    required super.sid,
    required super.device,
    required super.properties,
    required this.processId,
    required this.processName,
    required this.fatal,
    required this.exception,
  }) : super(type: "managedError");

  ManagedErrorLog.fromMap(super.map)
    : processId = map['processId'],
      processName = map['processName'],
      fatal = map['fatal'],
      exception = ExceptionLog.fromMap(map['exception']),
      super.fromMap();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'processId': processId,
      'processName': processName,
      'fatal': fatal,
      'exception': exception.toMap(),
    });
    return map;
  }

  @override
  String toString() {
    return 'ManagedErrorLog${toMap()}';
  }
}

/// The Exception model.
class ExceptionLog {
  /// Exception type (fully qualified class name).
  final String type;

  /// Exception message.
  final String message;

  /// Raw stack trace. Sent when the frames property is either missing or unreliable (used for Xamarin exceptions).
  final String stackTrace;

  ExceptionLog({
    required this.type,
    required this.message,
    required this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'message': message,
      'stackTrace': stackTrace,
    };
  }

  ExceptionLog.fromMap(Map<String, dynamic> map)
    : type = map['type'],
      message = map['message'],
      stackTrace = map['stackTrace'];

  @override
  String toString() {
    return 'ExceptionLog${toMap()}';
  }
}
