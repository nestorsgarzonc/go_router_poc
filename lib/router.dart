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
  final state = ref.read(routerNotifierProvider.notifier);
  return GoRouter(
    initialLocation: OnBoardingScreen.route,
    navigatorKey: globalKey,
    refreshListenable: ref.watch(routerNotifierProvider.notifier),
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      return Text('${state.error}');
    },
    routes: state.routes,
    redirect: state.redirect,
  );
});

class CustomRouter extends Notifier<void> implements Listenable {
  VoidCallback? routerListener;
  bool isAuth = false;

  final routes = [
    GoRoute(
      path: OnBoardingScreen.route,
      name: OnBoardingScreen.route,
      builder: (context, state) => const OnBoardingScreen(),
    ),
    ..._counterRouter,
  ];

  static final _counterRouter = <RouteBase>[
    GoRoute(
      path: CounterPage.route,
      name: CounterPage.route,
      builder: (context, state) => const CounterPage(),
    ),
    GoRoute(
      onExit: (BuildContext context) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: const Text('Are you sure to leave this page?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
        return confirmed ?? false;
      },
      path: ProtectedCounterPage.path,
      name: ProtectedCounterPage.route,
      builder: (context, state) {
        //state.extra
        final title = state.pathParameters['title'];
        if (title == null) {
          return ErrorWidget(attributeErrorMessage('title'));
        }
        return ProtectedCounterPage(
          title: title,
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
