import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'appcenter_analytics.dart';

/// Signature for a function that extracts a screen name from [RouteSettings].
///
/// Usually, the route name is not a plain string, and it may contains some
/// unique ids that makes it difficult to aggregate over them in AppCenter
/// Analytics.
typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

/// [RouteFilter] allows to filter out routes that should not be tracked.
///
/// By default, only [PageRoute]s are tracked.
typedef RouteFilter = bool Function(Route<dynamic>? route);

bool defaultRouteFilter(Route<dynamic>? route) => route is PageRoute;

/// A [NavigatorObserver] that sends events to AppCenter Analytics when the
/// currently active [ModalRoute] changes.
/// (similar with FirebaseAnalyticsObserver)
///
/// When a route is pushed or popped, and if [routeFilter] is true,
/// [nameExtractor] is used to extract a name  from [RouteSettings] of the now
/// active route and that name is sent to AppCenter Analytics.
///
/// The following operations will result in sending a screen view event:
/// ```dart
/// Navigator.pushNamed(context, '/contact/123');
///
/// Navigator.push<void>(context, MaterialPageRoute(
///   settings: RouteSettings(name: '/contact/123'),
///   builder: (_) => ContactDetail(123)));
///
/// Navigator.pushReplacement<void>(context, MaterialPageRoute(
///   settings: RouteSettings(name: '/contact/123'),
///   builder: (_) => ContactDetail(123)));
///
/// Navigator.pop(context);
/// ```
///
/// To use it, add it to the `navigatorObservers` of your [Navigator], e.g. if
/// you're using a [MaterialApp]:
/// ```dart
/// MaterialApp(
///   home: MyAppHome(),
///   navigatorObservers: [
///     AppCenterAnalyticsObserver(),
///   ],
/// );
/// ```
///
/// You can also track screen views within your [ModalRoute] by implementing
/// [RouteAware<ModalRoute<dynamic>>] and subscribing it to [AppCenterAnalyticsObserver]. See the
/// [RouteObserver<ModalRoute<dynamic>>] docs for an example.
class AppCenterAnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  static final Logger _log = Logger((AppCenterAnalyticsObserver).toString());

  /// Creates a [NavigatorObserver] that sends events to [AppCenterAnalytics].
  ///
  /// When a route is pushed or popped, [nameExtractor] is used to extract a
  /// name from [RouteSettings] of the now active route and that name is sent to
  /// AppCenter. Defaults to `defaultNameExtractor`.
  AppCenterAnalyticsObserver({
    this.nameExtractor = defaultNameExtractor,
    this.routeFilter = defaultRouteFilter,
  });

  final ScreenNameExtractor nameExtractor;
  final RouteFilter routeFilter;

  void _sendScreenView(Route<dynamic> route) {
    final String? screenName = nameExtractor(route.settings);
    if (screenName != null) {
      try {
        AppCenterAnalytics.trackEvent(
          "screen_view",
          properties: {"screenName": _truncate(screenName, 256)},
        );
      } catch (e, s) {
        _log.severe("Cannot send screen view event", e, s);
      }
    }
  }

  String _truncate(String value, int limit) {
    if (value.length <= limit) {
      return value;
    }
    return value.substring(0, limit);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (routeFilter(route)) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && routeFilter(newRoute)) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null &&
        routeFilter(previousRoute) &&
        routeFilter(route)) {
      _sendScreenView(previousRoute);
    }
  }
}
