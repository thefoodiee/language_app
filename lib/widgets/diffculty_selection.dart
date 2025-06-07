import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../controller/letter_match_controller.dart';
import '../screens/match_the_case.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final LetterMatchController controller;

  const DifficultySelectionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    void startGame(Difficulty difficulty) {
      controller.setDifficulty(difficulty);
      context.pushReplacementTransition(
        type: PageTransitionType.fade,
        child: LetterMatchScreen(controller: controller)
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat"
              ),
            ),
            const SizedBox(height: 30),
            _buildButton('Easy (3 letters)', () => startGame(Difficulty.easy)),
            _buildButton('Medium (5 letters)', () => startGame(Difficulty.medium)),
            _buildButton('Hard (7 letters)', () => startGame(Difficulty.hard)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: const Color(0xFFAF4128),
          foregroundColor: Color(0xFFFDF4EB),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Montserrat"),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
