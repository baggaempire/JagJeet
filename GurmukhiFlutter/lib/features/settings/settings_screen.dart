import 'package:flutter/material.dart';

import '../../models/app_language.dart';
import '../../models/source_type.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final prefs = appState.preferences;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Language'),
            subtitle: Text(prefs.preferredLanguage.displayName),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: AppLanguage.values
                  .map(
                    (lang) => ChoiceChip(
                      label: Text(lang.displayName),
                      selected: prefs.preferredLanguage == lang,
                      onSelected: (_) => appState.setLanguage(lang),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notifications'),
            value: prefs.notificationsEnabled,
            onChanged: appState.setNotificationsEnabled,
          ),
          const Divider(),
          const ListTile(title: Text('Sources')),
          ...SourceType.values.map(
            (source) => CheckboxListTile(
              title: Text(source.displayName),
              value: prefs.selectedSources.contains(source),
              onChanged: (checked) {
                final next = prefs.selectedSources.toSet();
                if (checked == true) {
                  next.add(source);
                } else {
                  next.remove(source);
                }
                appState.setSources(next.toList());
              },
            ),
          ),
        ],
      ),
    );
  }
}
