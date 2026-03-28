import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../reflection/reflection_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final items = appState.filteredReflections;

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final entry = items[index];
          return Card(
            child: ListTile(
              title: Text(entry.title.isEmpty ? entry.id : entry.title),
              subtitle: Text(entry.sourceType.displayName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReflectionScreen(entry: entry, appState: appState),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
