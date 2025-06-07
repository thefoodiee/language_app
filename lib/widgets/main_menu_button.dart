import 'package:flutter/material.dart';

class MainMenuImageButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final double elevation;

  const MainMenuImageButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
    required this.backgroundColor,
    this.elevation = 10,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: elevation,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
