import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router_poc/auth_provider.dart';

class ProtectedCounterPage extends ConsumerStatefulWidget {
  static const route = '/counter-secret';
  static const path = '$route/:title';
  static Map<String, String> getPathParams(String title) => {'title': title};

  const ProtectedCounterPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ProtectedCounterPage> createState() => _ProtectedCounterPageState();
}

class _ProtectedCounterPageState extends ConsumerState<ProtectedCounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: () {
              ref.read(authProvider.notifier).setUnauthenticated();
            }, child: Text('Logout'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
