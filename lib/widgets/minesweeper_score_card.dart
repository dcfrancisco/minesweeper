import 'package:flutter/material.dart';
import 'dart:async';

class MinesweeperScoreCard extends StatefulWidget {
  const MinesweeperScoreCard({
    super.key,
    required this.mineCount,
    required this.gameStarted,
    required this.gameEnded,
    required this.onReset,
    required this.gameWon,
  });

  final ValueNotifier<int> mineCount;
  final ValueNotifier<bool> gameStarted;
  final ValueNotifier<bool> gameEnded;
  final ValueNotifier<bool> gameWon;
  final VoidCallback onReset;

  @override
  State<MinesweeperScoreCard> createState() => _MinesweeperScoreCardState();
}

class _MinesweeperScoreCardState extends State<MinesweeperScoreCard> {
  late Timer _timer;
  int _seconds = 0;
  bool _timerActive = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);

    // Listen for game state changes
    widget.gameStarted.addListener(_onGameStateChanged);
    widget.gameEnded.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.gameStarted.removeListener(_onGameStateChanged);
    widget.gameEnded.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _updateTimer(Timer timer) {
    if (_timerActive && !widget.gameEnded.value) {
      setState(() {
        _seconds++;
        // Cap at 999 seconds like classic Minesweeper
        if (_seconds > 999) _seconds = 999;
      });
    }
  }

  void _onGameStateChanged() {
    setState(() {
      if (widget.gameStarted.value && !widget.gameEnded.value) {
        _timerActive = true;
      } else {
        _timerActive = false;
      }

      // Reset timer when game resets
      if (!widget.gameStarted.value) {
        _seconds = 0;
      }
    });
  }

  void _onResetPressed() {
    setState(() {
      _seconds = 0;
      _timerActive = false;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[600]!, width: 2),
        boxShadow: [
          // Inset border effect
          BoxShadow(
            color: Colors.white,
            offset: const Offset(1, 1),
            blurRadius: 0,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: Colors.grey[700]!,
            offset: const Offset(-1, -1),
            blurRadius: 0,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mine count display
          _buildDigitalDisplay(widget.mineCount),

          // Smiley reset button
          _buildSmileyButton(),

          // Timer display
          _buildDigitalDisplay(ValueNotifier(_seconds)),
        ],
      ),
    );
  }

  Widget _buildDigitalDisplay(ValueNotifier<int> value) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, count, child) {
        // Format as 3-digit display like classic Minesweeper
        final displayText = count.toString().padLeft(3, '0');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            displayText,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmileyButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.gameEnded,
      builder: (context, gameEnded, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.gameWon,
          builder: (context, gameWon, child) {
            String smileyText;
            Color backgroundColor;

            if (gameEnded) {
              if (gameWon) {
                smileyText = '😎'; // Cool sunglasses for win
                backgroundColor = Colors.green[200]!;
              } else {
                smileyText = '😵'; // Dead for loss
                backgroundColor = Colors.red[200]!;
              }
            } else {
              smileyText = '🙂'; // Normal smiley
              backgroundColor = Colors.grey[300]!;
            }

            return GestureDetector(
              onTap: _onResetPressed,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    // Raised button effect
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-1, -1),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.grey[700]!,
                      offset: const Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(smileyText, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
