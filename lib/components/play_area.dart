import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/main_sweeper.dart';

import '../config.dart';

class PlayArea extends RectangleComponent with HasGameReference<MineSweeper> {
  PlayArea()
    : super(
        position: Vector2.zero(),
        size: Vector2(gameWidth, gameHeight),
        paint: Paint()..color = const Color(0xFF222222),
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
