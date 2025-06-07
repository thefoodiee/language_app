import 'package:flutter/material.dart';

class CapitalLetterDisplay extends StatelessWidget {
  final String letter;
  final VoidCallback onVolumeTap;

  const CapitalLetterDisplay({
    super.key,
    required this.letter,
    required this.onVolumeTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          letter,
          style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: size.height * 0.5,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFAF4128),
            shadows: [
              Shadow(color: Colors.grey, offset: Offset(0, 2), blurRadius: 5),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onVolumeTap,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: Colors.black, width: 2),
            padding: const EdgeInsets.all(16),
          ),
          child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.black,
            size: 30,
          ),
        ),
      ],
    );
  }
}
