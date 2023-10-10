import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_poc/auth_provider.dart';
import 'package:go_router_poc/counter_screen.dart';
import 'package:go_router_poc/onboarding_screen.dart';
import 'package:go_router_poc/protected_counter_screen.dart';

final routerNotifierProvider = NotifierProvider<CustomRouter, void>(() => CustomRouter());
final globalKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);
  return GoRouter(
    initialLocation: OnBoardingScreen.route,
    navigatorKey: globalKey,
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      return ErrorWidget(state.error!);
    },
    routes: notifier.routes,
    redirect: notifier.redirect,
  );
});

class CustomRouter extends Notifier<void> implements Listenable {
  VoidCallback? routerListener;
  bool isAuth = false;

  final routes = [
    GoRoute(
      path: OnBoardingScreen.route,
      name: OnBoardingScreen.route,
      builder: (context, state) => OnBoardingScreen(
        key: state.pageKey,
      ),
    ),
    ..._counterRouter,
  ];

  static final _counterRouter = <RouteBase>[
    GoRoute(
      path: CounterPage.route,
      name: CounterPage.route,
      builder: (context, state) => CounterPage(
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: ProtectedCounterPage.path,
      name: ProtectedCounterPage.route,
      builder: (context, state) {
        final title = state.pathParameters['title'];
        if (title == null) {
          return ErrorWidget(attributeErrorMessage('title'));
        }
        return ProtectedCounterPage(
          title: title,
          key: state.pageKey,
        );
      },
    ),
  ];

  static String attributeErrorMessage(String attribute) {
    return 'Es necesario el parámetro $attribute';
  }

  Set<String> unAuthenticatedRoutes = {
    CounterPage.route,
    OnBoardingScreen.route,
  };

  String? redirect(BuildContext context, GoRouterState state) {
    final isAnAuthenticatedRoute = !unAuthenticatedRoutes.contains(state.matchedLocation);
    if (isAnAuthenticatedRoute && !isAuth) {
      return OnBoardingScreen.route;
    } else {
      return null;
    }
  }

  @override
  void addListener(VoidCallback listener) => routerListener = listener;

  @override
  FutureOr<void> build() =>
      ref.listen(authProvider.select((state) => state.status), (previous, next) {
        if (previous == next) return;
        isAuth = next.isAuthenticated;
        routerListener?.call();
      });

  @override
  void removeListener(VoidCallback listener) => routerListener = null;
}
