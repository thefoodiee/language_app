import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Difficulty { easy, medium, hard }

class LetterMatchController {

  LetterMatchController({this.difficulty = Difficulty.medium});

  final player = AudioPlayer();
  final applausePlayer = AudioPlayer();
  final confettiController = ConfettiController();
  final List<String> lettersToPlay = ["A",  "B",  "C",  "D",  "E",  "F",  "G",  "H",  "I",  "J",
    "K",  "L",  "M",  "N",  "O",  "P",  "Q",  "R",  "S",
    "T",  "U",  "V",  "W",  "X",  "Y",  "Z"];
  Random rng = Random();
  String? previousLetter;
  double buttonSize = 75;
  double padding = 15;
  final double boxPadding = 40;
  int attempts = 0;
  List<String> confusionEncountered = [];

  int currentIndex = 0;
  late String capitalLetter;
  late List<String> letters;
  final Map<String, Offset> letterPositions = {};
  final Random random = Random();

  bool correctSelected = false;
  bool confettiPlayed = false;

  late DateTime startTime;

  Difficulty difficulty = Difficulty.medium;

  void init() {
    capitalLetter = _getNewCapitalLetter();
    letters = generateLetters();
    startTimer();
    attempts = 0;
    confusionEncountered = [];
  }

  void dispose() {
    confettiController.dispose();
    player.dispose();
    applausePlayer.dispose();
  }

  void setDifficulty(Difficulty level) {
    difficulty = level;
  }

  String _getNewCapitalLetter() {
    String newLetter;
    if (previousLetter == null) {
      newLetter = lettersToPlay[rng.nextInt(lettersToPlay.length)];
    } else {
      do {
        newLetter = lettersToPlay[rng.nextInt(lettersToPlay.length)];
      } while (newLetter == previousLetter);
    }
    previousLetter = newLetter;
    return newLetter;
  }

  void startTimer(){
    startTime = DateTime.now();
  }

  Duration endTimer(){
    return DateTime.now().difference(startTime);
  }

  List<String> generateLetters() {
    final Map<String, List<String>> confusionPairs = {
      'B': ['b', 'd'],
      'D': ['d', 'b'],
      'M': ['m', 'n'],
      'N': ['n', 'm'],
      'P': ['p', 'q'],
      'Q': ['q', 'p'],
      'U': ['u', 'v'],
      'V': ['v', 'u'],
      'W': ['w', 'v'],
      'Z': ['z', 's'],
      'S': ['s', 'z'],
    };

    final correct = capitalLetter.toLowerCase();
    final List<String> pool = 'abcdefghijklmnopqrstuvwxyz'.split('');

    int targetCount = switch (difficulty) {
      Difficulty.easy => 3,
      Difficulty.medium => 5,
      Difficulty.hard => 7,
    };

    Set<String> result = {correct};
    if (confusionPairs.containsKey(capitalLetter)) {
      result.addAll(confusionPairs[capitalLetter]!);
    }

    pool.removeWhere((char) => result.contains(char));
    pool.shuffle();
    while (result.length < targetCount && pool.isNotEmpty) {
      result.add(pool.removeLast());
    }

    List<String> finalLetters = result.toList();
    finalLetters.shuffle();
    return finalLetters;
  }

  Future<void> handleTap(String letter, VoidCallback onCorrect) async {
    if (correctSelected) return;
    attempts++;

    if (letter == capitalLetter.toLowerCase()) {
      final duration = endTimer();
      correctSelected = true;

      saveDetailedRecord(
        capitalLetter: capitalLetter,
        totalDuration: duration,
        attempts: attempts,
        confusionTapped: confusionEncountered,
      );

      await player.play(AssetSource("sounds/letters/$capitalLetter.mp3"));
      await Future.delayed(const Duration(milliseconds: 800));
      await applausePlayer.play(AssetSource("sounds/ui/applause.mp3"));
      if (!confettiPlayed) {
        confettiPlayed = true;
        confettiController.play();
        Future.delayed(Duration(seconds: 1), () => confettiController.stop());
      }
      onCorrect();
    } else {
      Vibration.vibrate(pattern: [50, 200, 50, 200], amplitude: 1);
      final confusionPairs = {
        'B': ['b', 'd'],
        'D': ['d', 'b'],
        'M': ['m', 'n'],
        'N': ['n', 'm'],
        'P': ['p', 'q'],
        'Q': ['q', 'p'],
        'U': ['u', 'v'],
        'V': ['v', 'u'],
        'W': ['w', 'v'],
        'Z': ['z', 's'],
        'S': ['s', 'z'],
      };

      if (confusionPairs[capitalLetter]?.contains(letter) == true) {
        confusionEncountered.add(letter);
      }
    }
  }

  void nextLetter() {
    startTimer();
    confettiController.stop();
    currentIndex = (currentIndex + 1) % lettersToPlay.length;
    capitalLetter = _getNewCapitalLetter();
    letters = generateLetters();
    correctSelected = false;
    confettiPlayed = false;
    letterPositions.clear();
    attempts = 0;
    confusionEncountered = [];
  }

  void generateRandomPositions(double width, double height) {
    letterPositions.clear();
    _adjustSizeForScreen(width, height);

    final availableWidth = width - (2 * boxPadding);
    final availableHeight = height - (2 * boxPadding);

    if (_shouldUseGridLayout(availableWidth, availableHeight)) {
      _generateGridPositions(availableWidth, availableHeight);
      return;
    }

    List<Rect> placedRects = [];
    int maxAttempts = 500;

    for (var letter in letters) {
      Rect? buttonRect;
      int attempts = 0;

      while (attempts < maxAttempts) {
        final x = boxPadding + random.nextDouble() * (availableWidth - buttonSize);
        final y = boxPadding + random.nextDouble() * (availableHeight - buttonSize);

        buttonRect = Rect.fromLTWH(x, y, buttonSize, buttonSize);

        if (!_isRectOverlapping(buttonRect, placedRects)) {
          break;
        }

        attempts++;
      }

      if (attempts >= maxAttempts) {
        _generateGridPositions(availableWidth, availableHeight);
        return;
      }

      placedRects.add(buttonRect!);
      letterPositions[letter] = Offset(buttonRect.left, buttonRect.top);
    }
  }

  void _adjustSizeForScreen(double width, double height) {
    final letterCount = letters.length;

    final availableArea = (width - 2 * boxPadding) * (height - 2 * boxPadding);
    final areaPerButton = availableArea / (letterCount * 2.5);
    final optimalSize = sqrt(areaPerButton).clamp(50.0, 90.0);

    buttonSize = optimalSize;
    padding = (buttonSize * 0.2).clamp(10.0, 20.0);
  }

  bool _shouldUseGridLayout(double availableWidth, double availableHeight) {
    final minSpaceRequired = letters.length * (buttonSize + padding) * (buttonSize + padding);
    final availableSpace = availableWidth * availableHeight;
    return minSpaceRequired > availableSpace * 0.7;
  }

  void _generateGridPositions(double availableWidth, double availableHeight) {
    final letterCount = letters.length;

    int cols = (sqrt(letterCount)).ceil();
    int rows = (letterCount / cols).ceil();

    while (cols * (buttonSize + padding) > availableWidth && cols > 1) {
      cols--;
      rows = (letterCount / cols).ceil();
    }

    final spacingX = (availableWidth - (cols * buttonSize)) / (cols + 1);
    final spacingY = (availableHeight - (rows * buttonSize)) / (rows + 1);

    final randomOffset = buttonSize * 0.1;

    for (int i = 0; i < letters.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;

      final baseX = boxPadding + spacingX + col * (buttonSize + spacingX);
      final baseY = boxPadding + spacingY + row * (buttonSize + spacingY);

      final randomX = (random.nextDouble() - 0.5) * randomOffset;
      final randomY = (random.nextDouble() - 0.5) * randomOffset;

      final x = (baseX + randomX).clamp(boxPadding, boxPadding + availableWidth - buttonSize);
      final y = (baseY + randomY).clamp(boxPadding, boxPadding + availableHeight - buttonSize);


      letterPositions[letters[i]] = Offset(x, y);
    }
  }

  bool _isRectOverlapping(Rect rect, List<Rect> placedRects) {
    final expandedRect = rect.inflate(padding);

    for (var placedRect in placedRects) {
      final expandedPlaced = placedRect.inflate(padding);
      if (expandedRect.overlaps(expandedPlaced)) {
        return true;
      }
    }
    return false;
  }

  Future<void> saveDetailedRecord({
    required String capitalLetter,
    required Duration totalDuration,
    required int attempts,
    required List<String> confusionTapped,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double timePerAttempt = totalDuration.inMilliseconds / attempts;
    double accuracy = 1.0 / attempts;

    await FirebaseFirestore.instance
        .collection('puzzleData')
        .doc(user.email)
        .collection('records')
        .add({
      'letter': capitalLetter,
      'duration_ms': totalDuration.inMilliseconds,
      'attempts': attempts,
      'time_per_attempt_ms': timePerAttempt,
      'accuracy': accuracy,
      'confusion_encountered': confusionTapped,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}