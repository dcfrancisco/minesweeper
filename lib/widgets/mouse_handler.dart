import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MouseHandler extends StatelessWidget {
  const MouseHandler({
    super.key,
    required this.child,
    required this.onLeftClick,
    required this.onRightClick,
  });

  final Widget child;
  final VoidCallback onLeftClick;
  final VoidCallback onRightClick;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == kPrimaryButton) {
          onLeftClick();
        } else if (event.buttons == kSecondaryButton) {
          onRightClick();
        }
      },
      child: child,
    );
  }
}
