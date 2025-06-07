import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_game/widgets/capital_letter_display.dart';
import 'package:language_game/widgets/confetti_overlay.dart';
import 'package:language_game/widgets/main_menu_button.dart';
import 'package:language_game/screens/main_menu.dart';
import 'package:page_transition/page_transition.dart';

import '../constants.dart';
import '../controller/letter_match_controller.dart';
import '../widgets/lower_letter_buttons.dart';

class LetterMatchScreen extends StatefulWidget {
  final LetterMatchController controller;

  const LetterMatchScreen({super.key, required this.controller});

  @override
  State<LetterMatchScreen> createState() => _LetterMatchScreenState();
}

class _LetterMatchScreenState extends State<LetterMatchScreen> {
  late final LetterMatchController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.init();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final halfWidth = size.width / 2;
    final scatterWidth = halfWidth - 2 * controller.boxPadding;
    final scatterHeight = size.height - 2 * controller.boxPadding;

    if (!controller.correctSelected && controller.letterPositions.isEmpty) {
      controller.generateRandomPositions(scatterWidth, scatterHeight);
    }

    return Stack(children: [
      Scaffold(
        body: Row(
          children: [
            Container(
              width: halfWidth,
              color: const Color(0xFFF4EFEC),
              child: CapitalLetterDisplay(
                letter: controller.capitalLetter,
                onVolumeTap: () {
                  controller.player.play(
                    AssetSource("sounds/letters/${controller.capitalLetter}.mp3"),
                  );
                },
              ),
            ),
            Container(
              width: halfWidth,
              color: mainRed,
              padding: EdgeInsets.all(controller.boxPadding),
              child: Center(
                child: controller.correctSelected
                    ? Text(
                  controller.capitalLetter.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: "Montserrat",
                  ),
                )
                    : LowercaseLetterButtons(
                  letters: controller.letters,
                  positions: controller.letterPositions,
                  buttonSize: controller.buttonSize,
                  onTap: (letter) {
                    controller.handleTap(letter, () {
                      setState(() {});
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: controller.correctSelected
            ? FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              controller.applausePlayer.stop();
              controller.nextLetter();
            });
          },
          backgroundColor: mainWhite,
          foregroundColor: mainRed,
          label: const Text("Next"),
          icon: const Icon(Icons.play_arrow_rounded),
        )
            : null,
      ),
      ConfettiOverlay(controller: controller.confettiController),
      Positioned(
        top: 16,
        right: 16,
        child: MainMenuImageButton(
          imagePath: "assets/images/mainMenuSettings.png",
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: MainMenu(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          size: 50,
        ),
      ),
    ]);
  }
}
