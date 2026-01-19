import 'package:flutter/foundation.dart';

import '../util/constants.dart';

/// Device characteristic log.
@immutable
class Device {
  /// Name of the SDK.
  final String sdkName;

  /// Version of the SDK.
  final String sdkVersion;

  /// Device model (example: iPad2,3).
  final String model;

  /// Device manufacturer (example: HTC).
  final String oemName;

  /// OS name (example: iOS).
  final String osName;

  /// OS version (example: 9.3.0).
  final String osVersion;

  /// Language code (example: en_US).
  final String locale;

  /// Screen size of the device in pixels (example: 640x480).
  final String screenSize;

  /// Application version name.
  final String appVersion;

  /// The app's build number, e.g. 42.
  final String appBuild;

  /// The bundle identifier, package identifier, or namespace,
  /// depending on what the individual platforms use
  final String appNamespace;

  const Device({
    this.sdkName = Constants.packageName,
    this.sdkVersion = Constants.packageVersion,
    required this.model,
    required this.oemName,
    required this.osName,
    required this.osVersion,
    required this.locale,
    required this.screenSize,
    required this.appVersion,
    required this.appBuild,
    required this.appNamespace,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sdkName': sdkName,
      'sdkVersion': sdkVersion,
      'model': model,
      'oemName': oemName,
      'osName': osName,
      'osVersion': osVersion,
      'locale': locale,
      'screenSize': screenSize,
      'appVersion': appVersion,
      'appBuild': appBuild,
      'appNamespace': appNamespace,
    };
  }

  Device.fromMap(Map<String, dynamic> map)
    : sdkName = map['sdkName'],
      sdkVersion = map['sdkVersion'],
      model = map['model'],
      oemName = map['oemName'],
      osName = map['osName'],
      osVersion = map['osVersion'],
      locale = map['locale'],
      screenSize = map['screenSize'],
      appVersion = map['appVersion'],
      appBuild = map['appBuild'],
      appNamespace = map['appNamespace'];

  @override
  String toString() {
    return 'Device${toMap()}';
  }
}
