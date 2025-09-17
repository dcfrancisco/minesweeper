import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class MineSweeper extends FlameGame with KeyboardEvents, TapDetector {
  MineSweeper()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  late PlayState gameState;
  late List<List<MineTile>> board;
  late int rows;
  late int cols;
  late int totalMines;
  late int flaggedMines;
  late int revealedTiles;
  late DateTime startTime;
  final Random _random = Random();

  // Callbacks for UI updates
  VoidCallback? onGameStateChanged;
  ValueNotifier<int>? mineCountNotifier;
  ValueNotifier<bool>? gameStartedNotifier;
  ValueNotifier<bool>? gameEndedNotifier;
  ValueNotifier<bool>? gameWonNotifier;

  void setUICallbacks({
    VoidCallback? onStateChanged,
    ValueNotifier<int>? mineCount,
    ValueNotifier<bool>? gameStarted,
    ValueNotifier<bool>? gameEnded,
    ValueNotifier<bool>? gameWon,
  }) {
    onGameStateChanged = onStateChanged;
    mineCountNotifier = mineCount;
    gameStartedNotifier = gameStarted;
    gameEndedNotifier = gameEnded;
    gameWonNotifier = gameWon;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameState = PlayState.welcome;

    // Initialize with beginner settings for now
    initializeGame(9, 9, 10);
  }

  void initializeGame(int gridRows, int gridCols, int mines) {
    rows = gridRows;
    cols = gridCols;
    totalMines = mines;
    flaggedMines = 0;
    revealedTiles = 0;
    gameState = PlayState.playing;
    startTime = DateTime.now();

    // Update UI notifiers
    mineCountNotifier?.value = totalMines;
    gameStartedNotifier?.value = true;
    gameEndedNotifier?.value = false;
    gameWonNotifier?.value = false;

    // Clear existing board
    removeAll(children.whereType<MineTile>());

    // Create new board
    board = List.generate(
      rows,
      (row) => List.generate(
        cols,
        (col) => MineTile(
          gridX: col,
          gridY: row,
          position: Vector2(
            col * (MineTile.tileSize + 1) + 50,
            row * (MineTile.tileSize + 1) + 100,
          ),
          size: Vector2.all(MineTile.tileSize),
        ),
      ),
    );

    // Add tiles to game
    for (final row in board) {
      for (final tile in row) {
        add(tile);
      }
    }

    // Place mines randomly
    _placeMines();

    // Calculate adjacent mine counts
    _calculateAdjacentMines();
  }

  void _placeMines() {
    int placedMines = 0;

    while (placedMines < totalMines) {
      final row = _random.nextInt(rows);
      final col = _random.nextInt(cols);

      if (!board[row][col].hasMine) {
        board[row][col].hasMine = true;
        placedMines++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (!board[row][col].hasMine) {
          int count = 0;

          // Check all 8 adjacent tiles
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;

              final newRow = row + dr;
              final newCol = col + dc;

              if (newRow >= 0 &&
                  newRow < rows &&
                  newCol >= 0 &&
                  newCol < cols &&
                  board[newRow][newCol].hasMine) {
                count++;
              }
            }
          }

          board[row][col].adjacentMines = count;
        }
      }
    }
  }

  void revealTile(int col, int row) {
    if (gameState != PlayState.playing) return;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;

    final tile = board[row][col];
    if (tile.state != TileState.covered) return;

    tile.reveal();
    revealedTiles++;

    if (tile.hasMine) {
      // Game over - reveal all mines
      _revealAllMines();
      gameState = PlayState.gameOver;
      gameEndedNotifier?.value = true;
      gameWonNotifier?.value = false;
      onGameStateChanged?.call();
    } else {
      // If tile has no adjacent mines, reveal adjacent tiles
      if (tile.adjacentMines == 0) {
        _revealAdjacentTiles(col, row);
      }

      // Check win condition
      if (revealedTiles == (rows * cols - totalMines)) {
        gameState = PlayState.won;
        gameEndedNotifier?.value = true;
        gameWonNotifier?.value = true;
        onGameStateChanged?.call();
      }
    }
  }

  void toggleFlag(int col, int row) {
    if (gameState != PlayState.playing) return;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;

    final tile = board[row][col];
    if (tile.state == TileState.revealed) return;

    if (tile.state == TileState.covered) {
      tile.state = TileState.flagged;
      flaggedMines++;
    } else if (tile.state == TileState.flagged) {
      tile.state = TileState.covered;
      flaggedMines--;
    }

    // Update mine count display
    mineCountNotifier?.value = totalMines - flaggedMines;
  }

  void _revealAdjacentTiles(int col, int row) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final newRow = row + dr;
        final newCol = col + dc;

        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
          revealTile(newCol, newRow);
        }
      }
    }
  }

  void _revealAllMines() {
    for (final row in board) {
      for (final tile in row) {
        if (tile.hasMine) {
          tile.reveal();
        }
      }
    }
  }

  void resetGame() {
    initializeGame(rows, cols, totalMines);
  }
}
