import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import '../main_sweeper.dart';
import 'difficulty_selector.dart';
import 'minesweeper_score_card.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late MineSweeper game;
  bool _showDifficultySelector = true;

  // Game state notifiers
  final ValueNotifier<int> mineCount = ValueNotifier<int>(10);
  final ValueNotifier<bool> gameStarted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> gameEnded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> gameWon = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    game = MineSweeper();

    // Set up UI callbacks
    game.setUICallbacks(
      mineCount: mineCount,
      gameStarted: gameStarted,
      gameEnded: gameEnded,
      gameWon: gameWon,
    );
  }

  void _onDifficultySelected(int rows, int cols, int mines) {
    setState(() {
      _showDifficultySelector = false;
      mineCount.value = mines;
      gameStarted.value = true;
      gameEnded.value = false;
      gameWon.value = false;
    });

    game.initializeGame(rows, cols, mines);
  }

  void _onGameReset() {
    setState(() {
      _showDifficultySelector = true;
      gameStarted.value = false;
      gameEnded.value = false;
      gameWon.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'PressStart2P'),
      home: Scaffold(
        backgroundColor: Colors.grey[300], // Classic Minesweeper background
        body: GestureDetector(
          onSecondaryTap: () {
            // Consume right-clicks at the scaffold level to prevent context menu
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // Score card at the top
                  if (!_showDifficultySelector)
                    MinesweeperScoreCard(
                      mineCount: mineCount,
                      gameStarted: gameStarted,
                      gameEnded: gameEnded,
                      gameWon: gameWon,
                      onReset: _onGameReset,
                    ),

                  // Game area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[300], // Game background color
                      child: Listener(
                        onPointerDown: (event) {
                          // Handle right-click at the widget level for better macOS support
                          if (event.buttons == 2) {
                            // Right mouse button
                            // This will be handled by individual tiles
                          }
                        },
                        child: GameWidget(game: game),
                      ),
                    ),
                  ),
                ],
              ),

              // Difficulty selector overlay
              if (_showDifficultySelector)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: DifficultySelector(onSelect: _onDifficultySelected),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
