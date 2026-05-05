import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../data/replay_repository.dart';
import '../main.dart';

class LeaderboardScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(GameReplay replay) onReplaySelected;

  const LeaderboardScreen({
    super.key,
    required this.onBack,
    required this.onReplaySelected,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late ReplayRepository _repo;
  late Stream<List<GameReplay>> _replayStream;

  @override
  void initState() {
    super.initState();
    _repo = context.read<ReplayRepository>();
    _replayStream = _repo.watchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: widget.onBack,
                  ),
                  Text(
                    'LEADERBOARD',
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.cyanAccent,
                      shadows: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.8),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<GameReplay>>(
                stream: _replayStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'ERROR LOADING LEADERBOARD',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  }

                  final replays = snapshot.data ?? [];
                  if (replays.isEmpty) {
                    return Center(
                      child: Text(
                        'NO SCORES YET',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.cyan.shade200,
                          fontSize: 24,
                        ),
                      ),
                    );
                  }

                  // Sort by score descending
                  replays.sort((a, b) => b.score.compareTo(a.score));

                  final String? currentInitials =
                      prefs.getString('user_name') ??
                      prefs.getString('user_initials');

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    itemCount: replays.length,
                    itemBuilder: (context, index) {
                      final replay = replays[index];
                      final isMine = replay.userId == currentInitials;
                      return _LeaderboardRow(
                        rank: index + 1,
                        replay: replay,
                        isMine: isMine,
                        onReplay: () => widget.onReplaySelected(replay),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatefulWidget {
  final int rank;
  final GameReplay replay;
  final bool isMine;
  final VoidCallback onReplay;

  const _LeaderboardRow({
    required this.rank,
    required this.replay,
    required this.isMine,
    required this.onReplay,
  });

  @override
  State<_LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<_LeaderboardRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                widget.isMine
                    ? Colors.amberAccent
                    : (isHovered ? Colors.pinkAccent : Colors.cyan.shade900),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              widget.isMine
                  ? Colors.amber.withValues(alpha: 0.1)
                  : (isHovered
                      ? Colors.pinkAccent.withValues(alpha: 0.1)
                      : Colors.transparent),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '#${widget.rank}',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.replay.userId + (widget.isMine ? ' (YOU)' : ''),
                    style: GoogleFonts.shareTechMono(
                      fontSize: 24,
                      color: widget.isMine ? Colors.amberAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LVL ${widget.replay.levelSeed} | ${(widget.replay.durationMs / 1000).toStringAsFixed(1)}s',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 14,
                      color: Colors.cyan.shade200,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${widget.replay.score}',
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(width: 32),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onReplay,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'REPLAY',
                    style: GoogleFonts.shareTechMono(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
