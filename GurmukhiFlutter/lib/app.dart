import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/daily_reflection_service.dart';
import 'services/notification_service.dart';
import 'services/preferences_store.dart';
import 'services/reflection_repository.dart';
import 'state/app_state.dart';

class GurmukhiApp extends StatefulWidget {
  const GurmukhiApp({super.key});

  @override
  State<GurmukhiApp> createState() => _GurmukhiAppState();
}

class _GurmukhiAppState extends State<GurmukhiApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      repository: ReflectionRepository(),
      dailyService: DailyReflectionService(),
      store: PreferencesStore(),
      notifications: NotificationService(),
    );
    _appState.initialize();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Gurmukhi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: _appState.preferences.hasCompletedOnboarding
              ? _RootTabs(appState: _appState)
              : OnboardingScreen(appState: _appState),
        );
      },
    );
  }
}

class _RootTabs extends StatefulWidget {
  const _RootTabs({required this.appState});

  final AppState appState;

  @override
  State<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<_RootTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(appState: widget.appState),
          LearnScreen(appState: widget.appState),
          SavedScreen(appState: widget.appState),
          SettingsScreen(appState: widget.appState),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (next) => setState(() => _index = next),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
