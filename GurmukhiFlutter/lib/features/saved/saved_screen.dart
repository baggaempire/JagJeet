import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../reflection/reflection_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final items = appState.bookmarkedEntries;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: items.isEmpty
          ? const Center(child: Text('No saved reflections yet.'))
          : ListView.builder(
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
