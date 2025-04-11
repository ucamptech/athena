import 'package:duolingo/question.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:ui';
import 'monk.dart';

class LetterGameScreen extends StatefulWidget {
  @override
  _LetterGameScreenState createState() => _LetterGameScreenState();
}

class _LetterGameScreenState extends State<LetterGameScreen> {
  final String word = "fox";
  List<String?> placedLetters = [null, null, null];
  List<String> availableLetters = ['f', 'o', 'x'];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool showContinueButton = false;

  final GameSession gameSession = GameSession(
    userID: 'user_123',
    loginDate: DateTime.now(),
  );

  late DateTime questionShownTime;
  late DateTime userActiveStartTime;

  @override
  void initState() {
    super.initState();
    _playSound();
    questionShownTime = DateTime.now();
    userActiveStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/fox.png', height: 150),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          word.length,
                              (index) => DragTarget<String>(
                            onAccept: (receivedLetter) {
                              setState(() {
                                placedLetters[index] = receivedLetter;
                                availableLetters.remove(receivedLetter);
                              });

                              Future.delayed(Duration(milliseconds: 300), () {
                                if (_isWordCorrect()) {
                                  _showCorrectBanner();
                                  setState(() {
                                    showContinueButton = true;
                                  });
                                }
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: 40,
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                  color: placedLetters[index] != null
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  placedLetters[index] ?? '',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...availableLetters.map((letter) {
                  return DraggableLetter(
                    letter: letter,
                    onDragCompleted: () {
                      setState(() {
                        availableLetters.remove(letter);
                      });
                    },
                    color: _getRandomColor(),
                  );
                }).toList(),
              ],
            ),
          ),
          if (showContinueButton)
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Create an ExerciseResult and add to session
                    final result = ExerciseResult(
                      exerciseID: 'fox_image',
                      assets: 'fox.png',
                      result: word,
                      timeActivityIsDisplayed: questionShownTime,
                      timeUserIsActive: DateTime.now(),
                    );

                    gameSession.exerciseList.add(result);

                    // ✅ Print the whole session as JSON in terminal
                    print(gameSession.toJson());
                    Navigator.pop(context, true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Monk()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/drag.mp3'));
  }

  Color _getRandomColor() {
    final random = Random();
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }

  bool _isWordCorrect() {
    for (int i = 0; i < word.length; i++) {
      if (placedLetters[i] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void _showCorrectBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Correct!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveExerciseResult() {
    final timeUserIsActive = DateTime.now();
    final exerciseResult = ExerciseResult(
      exerciseID: 'exercise_01',
      assets: {'image': 'fox.png'},
      result: _isWordCorrect() ? 'correct' : 'incorrect',
      timeActivityIsDisplayed: questionShownTime,
      timeUserIsActive: timeUserIsActive,
    );
    gameSession.exerciseList.add(exerciseResult);
    gameSession.accumulatedSessionScore += _isWordCorrect() ? 10 : 0;

    print(gameSession.toJson()); // Print out the GameSession as JSON
  }
}

class DraggableLetter extends StatelessWidget {
  final String letter;
  final VoidCallback onDragCompleted;
  final Color color;

  DraggableLetter({
    required this.letter,
    required this.onDragCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (100 + (letter.hashCode % 200)).toDouble(),
      top: (300 + (letter.hashCode % 150)).toDouble(),
      child: Draggable<String>(
        data: letter,
        feedback: Material(
          color: Colors.transparent,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 30,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        childWhenDragging: SizedBox.shrink(),
        onDragCompleted: onDragCompleted,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 30,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==== Model Classes ====
// ExerciseResult class
class ExerciseResult {
  final String exerciseID;
  final dynamic assets;
  final String result;
  final DateTime timeActivityIsDisplayed;
  final DateTime timeUserIsActive;

  ExerciseResult({
    required this.exerciseID,
    required this.assets,
    required this.result,
    required this.timeActivityIsDisplayed,
    required this.timeUserIsActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseID': exerciseID,
      'assets': assets,
      'result': result,
      'timeActivityIsDisplayed': timeActivityIsDisplayed.toIso8601String(),
      'timeUserIsActive': timeUserIsActive.toIso8601String(),
    };
  }
}

// GameSession class
class GameSession {
  final String userID;
  final DateTime loginDate;
  int accumulatedSessionScore;
  final List<ExerciseResult> exerciseList;

  GameSession({
    required this.userID,
    required this.loginDate,
    this.accumulatedSessionScore = 0,
    List<ExerciseResult>? exerciseList,
  }) : exerciseList = exerciseList ?? [];

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'loginDate': loginDate.toIso8601String(),
      'accumulatedSessionScore': accumulatedSessionScore,
      'exerciseList': exerciseList.map((e) => e.toJson()).toList(),
    };
  }
}
