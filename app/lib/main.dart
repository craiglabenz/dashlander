import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashlander/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/dashlander_game.dart';
import 'game/game_state.dart';
import 'game/level_generator.dart';
import 'package:shared/shared.dart';
import 'ui/game_over_modal.dart';
import 'ui/hud_overlay.dart';
import 'ui/leaderboard_screen.dart';
import 'ui/level_select.dart';
import 'ui/main_menu.dart';
import 'ui/sandbox_setup.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/hive_adapters.dart';
import 'data/replay_repository.dart';

late FirebaseFirestore firestore;
late ReplayRepository replayRepository;
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firestore = FirebaseFirestore.instance;

  final hiveInit = Hive.initFlutter().then((_) {
    Hive.registerAdapter(GameReplayAdapter());
    Hive.registerAdapter(ThrusterActionAdapter());
    Hive.registerAdapter(ThrusterTypeAdapter());
  });

  prefs = await SharedPreferences.getInstance();

  replayRepository = ReplayRepository(firestore: firestore, hiveInit: hiveInit);

  runApp(const DashlanderApp());
}

class DashlanderApp extends StatelessWidget {
  const DashlanderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseFirestore>.value(value: firestore),
        Provider<ReplayRepository>.value(value: replayRepository),
      ],
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
  bool _showLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _controller.status.addListener(() async {
      if (_controller.status.value == GameStatus.won ||
          _controller.status.value == GameStatus.lost) {
        if (_controller.lastReplay != null) {
          String? initials = prefs.getString('user_initials');
          if (initials == null) {
            initials = await _promptForInitials();
            if (initials != null && initials.trim().isNotEmpty) {
              await prefs.setString('user_initials', initials.trim());
            } else {
              initials = 'ANON';
            }
          }

          final replayToSave = _controller.lastReplay!.copyWith(
            userId: initials,
          );
          await replayRepository.setItem(replayToSave);
        }
      }
      setState(() {}); // Rebuild UI based on status
    });
  }

  Future<String?> _promptForInitials() async {
    String? initials;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String currentInput = '';
        return AlertDialog(
          title: const Text('Enter Initials'),
          content: TextField(
            maxLength: 3,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'e.g. AAA'),
            onChanged: (val) => currentInput = val,
          ),
          actions: [
            TextButton(
              onPressed: () {
                initials = currentInput.toUpperCase();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return initials;
  }

  void _startGame(
    LevelData level, {
    SandboxConfig? config,
    GameReplay? targetGhostReplay,
  }) {
    _controller.reset();
    _controller.currentLevel = level;
    _controller.sandboxConfig = config;
    _controller.targetGhostReplay = targetGhostReplay;
    _game = DashlanderGame(gameController: _controller);
    setState(() {
      _showLeaderboard = false;
    });
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
          if (_showLeaderboard)
            LeaderboardScreen(
              onBack: () => setState(() => _showLeaderboard = false),
              onReplaySelected: (replay) {
                // Find the level
                final lvl = LevelGenerator.generate(seed: replay.levelSeed);
                _startGame(lvl, targetGhostReplay: replay);
              },
            )
          else if (status == GameStatus.menu)
            MainMenu(
              onPlayCampaign: _showCampaignMenu,
              onPlaySandbox: _showSandboxMenu,
              onLeaderboard: () => setState(() => _showLeaderboard = true),
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
