import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_poc/auth_provider.dart';
import 'package:go_router_poc/protected_counter_screen.dart';

class CounterPage extends ConsumerStatefulWidget {
  static const route = '/counter';
  const CounterPage({super.key});

  @override
  ConsumerState<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ConsumerState<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).setAuthenticated();
                GoRouter.of(context).pushNamed(
                  ProtectedCounterPage.route,
                  pathParameters: ProtectedCounterPage.getPathParams('Secret $_counter'),
                );
              },
              child: Text('Go to Protected route'),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).pushNamed(
                  ProtectedCounterPage.route,
                  pathParameters: ProtectedCounterPage.getPathParams('Secret $_counter'),
                );
              },
              child: Text('Go to Protected route no auth'),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
