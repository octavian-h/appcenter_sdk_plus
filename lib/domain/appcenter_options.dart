import 'package:flutter/foundation.dart';

import 'device.dart';

@immutable
class AppCenterOptions {
  final Duration sendLogsTimeout;
  final int logsBatchSize;
  final Duration minDelayBetweenRequests;
  final String? logsDbPath;
  final String? installId;
  final Device? device;

  const AppCenterOptions({
    this.sendLogsTimeout = const Duration(seconds: 10),
    this.logsBatchSize = 5,
    this.minDelayBetweenRequests = const Duration(seconds: 15),
    this.logsDbPath,
    this.installId,
    this.device,
  });

  AppCenterOptions.fromMap(Map<String, dynamic> map)
    : sendLogsTimeout = map['sendLogsTimeout'],
      logsBatchSize = map['logsBatchSize'],
      minDelayBetweenRequests = map['minDelayBetweenRequests'],
      logsDbPath = map['logsDbPath'],
      installId = map['installId'],
      device = Device.fromMap(map['device']);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sendLogsTimeout': sendLogsTimeout,
      'logsBatchSize': logsBatchSize,
      'minDelayBetweenRequests': minDelayBetweenRequests,
      'logsDbPath': logsDbPath,
      'installId': installId,
      'device': device?.toMap(),
    };
  }

  @override
  String toString() {
    return 'AppCenterOptions${toMap()}';
  }
}
