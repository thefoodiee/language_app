import 'dart:math';

import 'package:flutter/material.dart';

class LowercaseLetterButtons extends StatelessWidget {
  final List<String> letters;
  final Map<String, Offset> positions;
  final double buttonSize;
  final Function(String) onTap;

  const LowercaseLetterButtons({
    super.key,
    required this.letters,
    required this.positions,
    required this.buttonSize,
    required this.onTap,
  });
  bool _isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final diagonal = sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    return diagonal > 1100 || mediaQuery.size.shortestSide > 600;
  }
  double _getFontSize(BuildContext context) {
    final isTablet = _isTablet(context);

    if (isTablet) {
      return buttonSize * 0.85;
    } else {
      return buttonSize * 0.5;
    }
  }

  double _getButtonSize(BuildContext context) {
    final isTablet = _isTablet(context);

    if (isTablet) {
      return buttonSize * 1.3;
    } else {
      return buttonSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: letters.map((letter) {
        final pos = positions[letter] ?? Offset.zero;
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: GestureDetector(
            onTap: () => onTap(letter),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              width: _getButtonSize(context),
              height: _getButtonSize(context),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFAF4128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: _getFontSize(context),
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF4EFEC),
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}