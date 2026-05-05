import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashlander/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unique_names_generator/unique_names_generator.dart' as ung;

import 'game/dashlander_game.dart';
import 'game/game_state.dart';
import 'game/level_generator.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared/shared.dart';
import 'dart:math';
import 'dart:async';
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

  try {
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.prefix = 'assets/audio/';
    FlameAudio.bgm.play('background.mp3');
  } catch (e) {
    debugPrint("Failed to load or play background music: $e");
  }

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
  bool _isMuteVisible = true;
  Timer? _muteTimer;

  void _toggleMute() {
    _controller.isMuted.value = !_controller.isMuted.value;
    if (_controller.isMuted.value) {
      FlameAudio.bgm.pause();
    } else {
      FlameAudio.bgm.resume();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.status.addListener(() async {
      final status = _controller.status.value;

      if (status == GameStatus.menu) {
        _muteTimer?.cancel();
        setState(() => _isMuteVisible = true);
      } else if (status == GameStatus.playing) {
        _muteTimer?.cancel();
        setState(() => _isMuteVisible = true);
        _muteTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isMuteVisible = false);
        });
      }

      if (status == GameStatus.won) {
        if (_controller.lastReplay != null) {
          String? userName =
              prefs.getString('user_name') ?? prefs.getString('user_initials');
          if (userName == null) {
            userName = await _promptForName();
            if (userName != null && userName.trim().isNotEmpty) {
              await prefs.setString('user_name', userName.trim());
            } else {
              userName = 'ANON';
            }
          }

          final replayToSave = _controller.lastReplay!.copyWith(
            userId: userName,
          );
          await replayRepository.setItem(replayToSave);
        }
      }
      setState(() {}); // Rebuild UI based on status
    });
  }

  @override
  void dispose() {
    _muteTimer?.cancel();
    super.dispose();
  }

  Future<String?> _promptForName() async {
    String? selectedName;
    final generator = ung.UniqueNamesGenerator(
      config: ung.Config(
        dictionaries: [ung.adjectives, ung.animals],
        style: ung.Style.capital,
        separator: ' ',
        length: 2,
      ),
    );

    String currentName = generator.generate();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      'Your assigned galactic identifier.',
                      style: GoogleFonts.shareTechMono(
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      currentName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shareTechMono(
                        color: Colors.cyanAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentName = generator.generate();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.pinkAccent,
                              side: const BorderSide(color: Colors.pinkAccent),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              'REROLL',
                              style: GoogleFonts.shareTechMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              selectedName = currentName;
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.cyanAccent,
                              side: const BorderSide(color: Colors.cyanAccent),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              'ACCEPT',
                              style: GoogleFonts.shareTechMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return selectedName;
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
              onNext: _playRandomSeed,
            ),

          // 3. Global Overlays
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isMuteVisible ? 1.0 : 0.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleMute,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _controller.isMuted,
                        builder: (context, isMuted, child) {
                          return Icon(
                            isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.cyanAccent,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
