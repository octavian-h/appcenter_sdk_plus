import 'package:appcenter_sdk_plus/appcenter_sdk_plus.dart';
import 'package:appcenter_sdk_plus/service/appcenter_analytics.dart';
import 'package:appcenter_sdk_plus/service/appcenter_analytics_observer.dart';
import 'package:appcenter_sdk_plus/service/appcenter_crashes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrintAppender.setupLogging(level: Level.FINE);

  await AppCenter.start("8e14e67c-7c91-40ac-8517-c62ece8424a6");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [
        AppCenterAnalyticsObserver(),
      ],
      initialRoute: LoadingPage.route,
      routes: {
        LoadingPage.route: (context) => const LoadingPage(),
        HomePage.route: (context) =>
            const HomePage(title: 'Flutter Demo Home Page'),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  static const String route = "/home";

  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  await AppCenterAnalytics.trackEvent("app_started",
                      properties: {"theme": "system"});
                },
                child: const Text("Submit event log"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    throw Exception("something");
                  } catch (e, s) {
                    await AppCenterCrashes.trackError(e, s);
                  }
                },
                child: const Text("Submit crash log"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  static const String route = "/";

  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<void>(
                future: Future.delayed(const Duration(seconds: 3)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.fromSize(
                          size: const Size(16, 16),
                          child: const CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }

                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, HomePage.route);
                  });
                  return Container();
                }),
          ],
        ),
      ),
    );
  }
}
