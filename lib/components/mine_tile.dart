import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MineTile extends PositionComponent {
  // ...tile state variables...

  @override
  void render(Canvas canvas) {
    // Draw base square
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..color = Colors.grey[300]!;

    // Draw beveled edges
    canvas.drawRect(rect, paint);
    // Top/left highlight
    canvas.drawLine(
      rect.topLeft,
      rect.topRight,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.bottomLeft,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    // Bottom/right shadow
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomRight,
      Paint()
        ..color = Colors.grey[700]!
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      rect.topRight,
      rect.bottomRight,
      Paint()
        ..color = Colors.grey[700]!
        ..strokeWidth = 2,
    );
  }
}
