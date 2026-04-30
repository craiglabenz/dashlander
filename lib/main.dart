import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import 'screens/level_select.dart';
import 'screens/sandbox_setup.dart';
import 'screens/game_screen.dart';
import 'models/models.dart';

void main() {
  runApp(const DashlanderApp());
}

class DashlanderApp extends StatelessWidget {
  const DashlanderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Lander',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'monospace',
      ),
      home: const AppController(),
    );
  }
}

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

enum AppView { menu, campaign, sandbox, game }

class _AppControllerState extends State<AppController> {
  AppView currentView = AppView.menu;
  LevelData? selectedLevel;
  SandboxConfig sandboxConfig = const SandboxConfig();

  void setView(AppView view) {
    setState(() => currentView = view);
  }

  void startGame(LevelData level, SandboxConfig config) {
    setState(() {
      selectedLevel = level;
      sandboxConfig = config;
      currentView = AppView.game;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case AppView.menu:
        return Scaffold(
          body: MainMenu(
            onPlayCampaign: () => setView(AppView.campaign),
            onPlaySandbox: () => setView(AppView.sandbox),
          ),
        );
      case AppView.campaign:
        return Scaffold(
          body: LevelSelect(
            onBack: () => setView(AppView.menu),
            onSelect: (level) => startGame(level, const SandboxConfig(infiniteFuel: false)),
          ),
        );
      case AppView.sandbox:
        return Scaffold(
          body: SandboxSetup(
            onBack: () => setView(AppView.menu),
            onStart: (config) => startGame(gameLevels.first, config),
          ),
        );
      case AppView.game:
        return GameScreen(
          level: selectedLevel!,
          sandboxConfig: sandboxConfig,
          onExit: () => setView(AppView.menu),
        );
    }
  }
}
