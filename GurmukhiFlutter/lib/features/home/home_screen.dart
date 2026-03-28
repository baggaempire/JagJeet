import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../reflection/reflection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = appState.todayReflection;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text('Today\'s Reflection'),
              subtitle: Text(today?.title ?? 'No reflection available'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: today == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReflectionScreen(entry: today, appState: appState),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}
