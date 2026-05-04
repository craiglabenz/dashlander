import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashlander/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'game/dashlander_game.dart';
import 'game/game_state.dart';
import 'game/level_generator.dart';
import 'package:shared/shared.dart';
import 'dart:math';
import 'ui/game_over_modal.dart';
import 'ui/hud_overlay.dart';
import 'ui/leaderboard_screen.dart';
import 'ui/main_menu.dart';
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
      if (_controller.status.value == GameStatus.won) {
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.cyanAccent, width: 2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PILOT REGISTRATION',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your 3-character identifier for the galactic leaderboard.',
                  style: GoogleFonts.shareTechMono(color: Colors.grey.shade400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  maxLength: 3,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.cyanAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                  cursorColor: Colors.cyanAccent,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'AAA',
                    hintStyle: GoogleFonts.shareTechMono(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 16,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.cyanAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.cyanAccent,
                        width: 3,
                      ),
                    ),
                  ),
                  onChanged: (val) => currentInput = val,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      initials = currentInput.toUpperCase();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.cyanAccent,
                      side: const BorderSide(color: Colors.cyanAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      'SAVE DESIGNATION',
                      style: GoogleFonts.shareTechMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  void _playRandomSeed() {
    final lvl = LevelGenerator.generate(seed: Random().nextInt(1000000));
    _startGame(lvl);
  }

  void _promptForSeed() async {
    int? seed = await _showSeedDialog();
    if (seed != null) {
      final lvl = LevelGenerator.generate(seed: seed);
      _startGame(lvl);
    }
  }

  Future<int?> _showSeedDialog() async {
    int? seed;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        String currentInput = '';
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.pinkAccent, width: 2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withValues(alpha: 0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ENTER SEED',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  maxLength: 12,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.pinkAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  cursorColor: Colors.pinkAccent,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '123456789',
                    hintStyle: GoogleFonts.shareTechMono(
                      color: Colors.pinkAccent.withValues(alpha: 0.2),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.pinkAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.pinkAccent,
                        width: 3,
                      ),
                    ),
                  ),
                  onChanged: (val) => currentInput = val,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      seed = int.tryParse(currentInput);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.pinkAccent,
                      side: const BorderSide(color: Colors.pinkAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      'START LEVEL',
                      style: GoogleFonts.shareTechMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return seed;
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
              onPlayRandom: _playRandomSeed,
              onEnterSeed: _promptForSeed,
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
                    targetGhostReplay: _controller.targetGhostReplay,
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
