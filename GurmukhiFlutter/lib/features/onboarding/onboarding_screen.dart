import 'package:flutter/material.dart';

import '../../models/app_language.dart';
import '../../models/source_type.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  AppLanguage _language = AppLanguage.english;
  final Set<SourceType> _sources = SourceType.values.toSet();
  bool _notifications = false;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choose language'),
          const SizedBox(height: 8),
          SegmentedButton<AppLanguage>(
            segments: AppLanguage.values
                .map((lang) => ButtonSegment(value: lang, label: Text(lang.displayName)))
                .toList(),
            selected: {_language},
            onSelectionChanged: (selection) => setState(() => _language = selection.first),
          ),
          const SizedBox(height: 20),
          const Text('Select sources'),
          const SizedBox(height: 8),
          ...SourceType.values.map(
            (source) => CheckboxListTile(
              title: Text(source.displayName),
              value: _sources.contains(source),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _sources.add(source);
                  } else {
                    _sources.remove(source);
                  }
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Enable notifications'),
            value: _notifications,
            onChanged: (next) => setState(() => _notifications = next),
          ),
          ListTile(
            title: const Text('Notification time'),
            subtitle: Text(_time.format(context)),
            onTap: () async {
              final selected = await showTimePicker(context: context, initialTime: _time);
              if (selected != null) {
                setState(() => _time = selected);
              }
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await widget.appState.completeOnboarding(
                selectedSources: _sources.isEmpty ? SourceType.values : _sources.toList(),
                language: _language,
                notificationsEnabled: _notifications,
                notificationHour: _time.hour,
                notificationMinute: _time.minute,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
