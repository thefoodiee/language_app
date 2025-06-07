import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:language_game/widgets/diffculty_selection.dart';
import 'package:language_game/widgets/main_menu_button.dart';
import 'package:language_game/widgets/main_menu_play_button.dart';
import 'package:page_transition/page_transition.dart';

import '../constants.dart';
import '../controller/letter_match_controller.dart';
import '../widgets/auth_dialog.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _refreshUserState() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFEC),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/images/mainMenuBG.png",
              height: double.infinity,
              fit: BoxFit.fitHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MainMenuImageButton(
                  imagePath: "assets/images/menuImage1.png",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AuthDialog(),
                      barrierDismissible: true,
                    ).then((_) {
                      _refreshUserState();
                    });
                  },
                  backgroundColor: mainWhite,
                  elevation: 4,
                  size: 60,
                ),
                MainMenuImageButton(
                  imagePath: "assets/images/mainMenuSettings.png",
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  size: 60,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        elevation: 10,
                        title: const Text(
                          "Exit Game",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        content: const Text(
                          "Are you sure you want to exit the game?",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop();
                              _refreshUserState();
                              await Future.delayed(const Duration(milliseconds: 100));
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AuthDialog(),
                                ).then((_) {
                                  _refreshUserState();
                                });
                              }
                            },
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                color: mainRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "No",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                color: mainRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => exit(0),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                color: mainRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 60,
            top: MediaQuery.of(context).size.height / 2 - 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Match The Case",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w900,
                    fontSize: 50,
                    color: mainRed,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.grey.shade400,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: MainMenuPlayButton(
                    onPressed: () {
                      if (user != null) {
                        context.pushReplacementTransition(
                          type: PageTransitionType.fade,
                          child: DifficultySelectionScreen(
                            controller: LetterMatchController(difficulty: Difficulty.medium),
                          ),
                        );
                        print("Logged in as: ${user?.email}");
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AuthDialog(),
                        ).then((_) {
                          _refreshUserState();
                        });
                        print("No user logged in");
                      }
                    },
                    text: "Play",
                    backgroundColor: mainRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}