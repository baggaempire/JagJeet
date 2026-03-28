import 'package:flutter/material.dart';

import '../../models/reflection_entry.dart';
import '../../state/app_state.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.entry,
    required this.appState,
  });

  final ReflectionEntry? entry;
  final AppState appState;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    if (entry == null) {
      return const Scaffold(body: Center(child: Text('No reflection available.')));
    }

    final pages = <MapEntry<String, String>>[
      MapEntry('Gurmukhi Verse', entry.gurmukhiText),
      MapEntry('English Meaning', entry.englishMeaning),
      MapEntry('Simple Explanation', entry.simpleExplanation),
      MapEntry('Reflection For Today', entry.lifeReflection),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title.isEmpty ? 'Reflection' : entry.title),
        actions: [
          IconButton(
            icon: Icon(
              widget.appState.isBookmarked(entry) ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () => widget.appState.toggleBookmark(entry),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final page = pages[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(page.key, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Expanded(child: SingleChildScrollView(child: Text(page.value))),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('${_index + 1}/${pages.length}'),
          ),
        ],
      ),
    );
  }
}
