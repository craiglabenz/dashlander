import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashlander/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/dashlander_game.dart';
import 'game/game_state.dart';
import 'ui/game_over_modal.dart';
import 'ui/hud_overlay.dart';
import 'ui/level_select.dart';
import 'ui/main_menu.dart';
import 'ui/sandbox_setup.dart';

late FirebaseFirestore firestore;

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firestore = FirebaseFirestore.instance;
  runApp(const DashlanderApp());
}

class DashlanderApp extends StatelessWidget {
  const DashlanderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseFirestore>.value(
      value: firestore,
      child: MaterialApp(
        title: 'Dashlander',
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        debugShowCheckedModeBanner: false,
        home: const GameCoordinator(),
      ),
    );
  }
}

class GameCoordinator extends StatefulWidget {
  const GameCoordinator({super.key});

  @override
  State<GameCoordinator> createState() => _GameCoordinatorState();
}

class _GameCoordinatorState extends State<GameCoordinator> {
  final GameController _controller = GameController();
  DashlanderGame? _game;

  @override
  void initState() {
    super.initState();
    _controller.status.addListener(() {
      setState(() {}); // Rebuild UI based on status
    });
  }

  void _startGame(LevelData level, {SandboxConfig? config}) {
    _controller.reset();
    _controller.currentLevel = level;
    _controller.sandboxConfig = config;
    _game = DashlanderGame(gameController: _controller);
    setState(() {});
  }

  void _showCampaignMenu(int ghostShipsCount) {
    setState(() {
      _game = null;
      _controller.ghostShipsCount = ghostShipsCount;
      _controller.status.value = GameStatus.playing; // Hack to show sub-menu
    });
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder:
          (_) => LevelSelect(
            onBack: () {
              Navigator.pop(context);
              _controller.reset();
            },
            onSelect: (lvl) {
              Navigator.pop(context);
              _startGame(lvl);
            },
          ),
    );
  }

  void _showSandboxMenu(int ghostShipsCount) {
    setState(() {
      _game = null;
      _controller.ghostShipsCount = ghostShipsCount;
      _controller.status.value = GameStatus.playing; // Hack to show sub-menu
    });
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder:
          (_) => SandboxSetup(
            onBack: () {
              Navigator.pop(context);
              _controller.reset();
            },
            onStart: (config, lvl) {
              Navigator.pop(context);
              _startGame(lvl, config: config);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _controller.status.value;

    return Scaffold(
      body: Stack(
        children: [
          // 1. The Flame Game Layer
          if (_game != null) GameWidget(game: _game!),

          // 2. UI Overlays
          if (status == GameStatus.menu)
            MainMenu(
              onPlayCampaign: _showCampaignMenu,
              onPlaySandbox: _showSandboxMenu,
            ),

          if ((status == GameStatus.playing ||
                  status == GameStatus.won ||
                  status == GameStatus.lost) &&
              _game != null)
            HudOverlay(
              controller: _controller,
              onExit: () {
                _game = null;
                _controller.reset();
              },
            ),

          if ((status == GameStatus.won || status == GameStatus.lost) &&
              _game != null)
            GameOverModal(
              controller: _controller,
              onRetry:
                  () => _startGame(
                    _controller.currentLevel!,
                    config: _controller.sandboxConfig,
                  ),
              onMenu: () {
                _game = null;
                _controller.reset();
              },
            ),
        ],
      ),
    );
  }
}
