import 'dart:io';

import 'package:appcenter_sdk_plus/appcenter_sdk_plus.dart';
import 'package:appcenter_sdk_plus/domain/appcenter_options.dart';
import 'package:appcenter_sdk_plus/domain/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testDbPath = "test.db";

  setUp(() async {
    if (await File(testDbPath).exists()) {
      await File(testDbPath).delete();
    }
  });

  tearDown(() async {
    await File(testDbPath).delete();
  });

  test("AppCenter start with success", () async {
    WidgetsFlutterBinding.ensureInitialized();

    var appCenter = await AppCenter.start(
      "8e14e67c-7c91-40ac-8517-c62ece8424a6",
      options: AppCenterOptions(
        logsDbPath: testDbPath,
        installId: "00000000-0000-0000-0000-000000000001",
        device: Device(
          model: "123",
          oemName: "Test",
          osName: Platform.operatingSystem,
          osVersion: Platform.operatingSystemVersion,
          locale: Platform.localeName,
          screenSize: "unknown",
          appVersion: "1.0",
          appBuild: "20",
          appNamespace: "com.example",
        ),
      ),
    );

    expect(appCenter.deviceService.device.model, "123");
    expect(appCenter.logService, isNotNull);
    expect(appCenter.sessionId, isNotNull);
    expect(appCenter.appLaunchTimestamp, isNotNull);
  });
}
