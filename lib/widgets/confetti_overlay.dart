import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const ConfettiOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: pi / 2,
        maxBlastForce: 10,
        minBlastForce: 5,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.2,
        shouldLoop: false,
      ),
    );
  }
}
