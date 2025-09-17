import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/main_sweeper.dart';

import '../config.dart';

class PlayArea extends RectangleComponent with HasGameReference<MineSweeper> {
  PlayArea()
    : super(
        position: Vector2.zero(),
        size: Vector2(gameWidth, gameHeight),
        paint: Paint()..color = Colors.grey[300]!,
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
