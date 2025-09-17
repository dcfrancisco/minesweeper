import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/main_sweeper.dart';
import 'dart:math' as math;

enum TileState { covered, revealed, flagged, questioned }

class MineTile extends PositionComponent
    with TapCallbacks, HasGameReference<MineSweeper> {
  MineTile({
    required this.gridX,
    required this.gridY,
    super.position,
    super.size,
  });

  final int gridX;
  final int gridY;

  TileState state = TileState.covered;
  bool hasMine = false;
  int adjacentMines = 0;

  static const double tileSize = 40.0;

  // Colors for different number values (classic Minesweeper)
  static const List<Color> numberColors = [
    Colors.transparent, // 0 - not used
    Color(0xFF0000FF), // 1 - blue
    Color(0xFF008000), // 2 - green
    Color(0xFFFF0000), // 3 - red
    Color(0xFF800080), // 4 - purple
    Color(0xFF800000), // 5 - maroon
    Color(0xFF008080), // 6 - teal
    Color(0xFF000000), // 7 - black
    Color(0xFF808080), // 8 - gray
  ];

  @override
  bool onTapDown(TapDownEvent event) {
    // For now, handle primary tap as left click
    _handleLeftClick();
    return true;
  }

  @override
  bool onLongTapDown(TapDownEvent event) {
    // Handle long press as right click for mobile-style flagging
    _handleRightClick();
    return true;
  }

  void onRightClick() {
    _handleRightClick();
  }

  void _handleLeftClick() {
    if (state == TileState.covered) {
      game.revealTile(gridX, gridY);
    }
  }

  void _handleRightClick() {
    if (state == TileState.covered) {
      state = TileState.flagged;
      game.toggleFlag(gridX, gridY);
    } else if (state == TileState.flagged) {
      state = TileState.covered;
      game.toggleFlag(gridX, gridY);
    }
  }

  void reveal() {
    state = TileState.revealed;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    if (state == TileState.revealed) {
      _drawRevealedTile(canvas, rect);
    } else {
      _drawCoveredTile(canvas, rect);
    }

    _drawContent(canvas, rect);
  }

  void _drawRevealedTile(Canvas canvas, Rect rect) {
    // Revealed tile - flat with inset appearance
    final paint = Paint()..color = hasMine ? Colors.red : Colors.grey[200]!;
    canvas.drawRect(rect, paint);

    // Inset border (darker on top/left, lighter on bottom/right)
    final borderPaint = Paint()..strokeWidth = 1;

    borderPaint.color = Colors.grey[600]!;
    canvas.drawLine(rect.topLeft, rect.topRight, borderPaint);
    canvas.drawLine(rect.topLeft, rect.bottomLeft, borderPaint);

    borderPaint.color = Colors.grey[400]!;
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, borderPaint);
    canvas.drawLine(rect.topRight, rect.bottomRight, borderPaint);
  }

  void _drawCoveredTile(Canvas canvas, Rect rect) {
    // Covered tile - raised 3D appearance
    final paint = Paint()..color = Colors.grey[300]!;
    canvas.drawRect(rect, paint);

    // Raised border (light on top/left, dark on bottom/right)
    final borderPaint = Paint()..strokeWidth = 2;

    borderPaint.color = Colors.white;
    canvas.drawLine(rect.topLeft, rect.topRight, borderPaint);
    canvas.drawLine(rect.topLeft, rect.bottomLeft, borderPaint);

    borderPaint.color = Colors.grey[700]!;
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, borderPaint);
    canvas.drawLine(rect.topRight, rect.bottomRight, borderPaint);
  }

  void _drawContent(Canvas canvas, Rect rect) {
    final center = rect.center;

    switch (state) {
      case TileState.flagged:
        _drawFlag(canvas, center);
        break;
      case TileState.questioned:
        _drawQuestion(canvas, center);
        break;
      case TileState.revealed:
        if (hasMine) {
          _drawMine(canvas, center);
        } else if (adjacentMines > 0) {
          _drawNumber(canvas, center, adjacentMines);
        }
        break;
      case TileState.covered:
        // No content for covered tiles
        break;
    }
  }

  void _drawFlag(Canvas canvas, Offset center) {
    final paint = Paint()..color = Colors.red;
    final flagRect = Rect.fromCenter(center: center, width: 12, height: 8);
    canvas.drawRect(flagRect, paint);

    // Flag pole
    final polePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - 6, center.dy - 4),
      Offset(center.dx - 6, center.dy + 8),
      polePaint,
    );
  }

  void _drawQuestion(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawMine(Canvas canvas, Offset center) {
    final paint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 8, paint);

    // Mine spikes
    final spikePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final start = center;
      final end = Offset(
        center.dx + 12 * math.cos(angle),
        center.dy + 12 * math.sin(angle),
      );
      canvas.drawLine(start, end, spikePaint);
    }
  }

  void _drawNumber(Canvas canvas, Offset center, int number) {
    if (number <= 0 || number > 8) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: numberColors[number],
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'PressStart2P',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
}
