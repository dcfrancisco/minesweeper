import 'package:flutter/material.dart';

class DifficultySelector extends StatelessWidget {
  final void Function(int rows, int cols, int mines) onSelect;

  const DifficultySelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Difficulty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _difficultyButton('Beginner', 9, 9, 10),
            const SizedBox(height: 12),
            _difficultyButton('Intermediate', 16, 16, 40),
            const SizedBox(height: 12),
            _difficultyButton('Expert', 16, 30, 99),
          ],
        ),
      ),
    );
  }

  Widget _difficultyButton(String label, int rows, int cols, int mines) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontFamily: 'PressStart2P'),
        ),
        onPressed: () => onSelect(rows, cols, mines),
        child: Text(label),
      ),
    );
  }
}
