import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import '../main_sweeper.dart';
import 'package:google_fonts/google_fonts.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.pressStart2p().fontFamily,
      ),
      home: GameWidget(game: MineSweeper()),
    );
  }
}
