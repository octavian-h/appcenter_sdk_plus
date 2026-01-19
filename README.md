# appcenter_sdk_plus

[![pub package](https://img.shields.io/pub/v/appcenter_sdk_plus.svg)](https://pub.dev/packages/appcenter_sdk_plus)

⚠️ Note: Microsoft is retiring App Center, more details on this [link](https://learn.microsoft.com/appcenter/retirement).

An AppCenter SDK written purely in Flutter to support multiple platforms. It provides a subset of
operations for AppCenter Analytics and AppCenter Crashes. More details about the AppCenter APIs can
be found on their [site](https://learn.microsoft.com/appcenter).

## Features

This package provides operations for:

- sending log events to AppCenter Analytics
- sending crash reports to AppCenter Crashes
- tracking screen views

## Getting started

To install this package run:

```bash
flutter pub add appcenter_sdk_plus
```

For Flutter applications you need to add the native SQLite library with:

```bash
flutter pub add sqlite3_flutter_libs
```

For other platforms, read [sqlite3 docs](https://pub.dev/packages/sqlite3#supported-platforms)

## Usage

```dart
import 'package:appcenter_sdk_plus/appcenter_sdk_plus.dart';
import 'package:appcenter_sdk_plus/service/appcenter_analytics.dart';
import 'package:appcenter_sdk_plus/service/appcenter_crashes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppCenter.start("8e14e67c-7c91-40ac-8517-c62ece8424a6");
  await AppCenterAnalytics.trackEvent("app_started",
      properties: {"theme": "system"});
  try {
    throw Exception("something");
  } catch (e, s) {
    await AppCenterCrashes.trackError(e, s,
        properties: {"reason": "Test trackError"});
  }
}
```

## Additional information

If you encounter any problems or you feel the library is missing a feature, please raise
a [ticket](https://github.com/octavian-h/appcenter_sdk_plus/issues) on
GitHub and I'll look into it. Pull request are also welcome.
