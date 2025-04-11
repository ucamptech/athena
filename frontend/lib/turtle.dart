import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:ui';
import 'turt.dart';

class TurtleGameScreen extends StatefulWidget {
  @override
  _TurtleGameScreenState createState() => _TurtleGameScreenState();
}

class _TurtleGameScreenState extends State<TurtleGameScreen> {
  final String word = "turtle";
  List<String?> placedLetters = [null, null, null, null, null, null, null];
  List<String> availableLetters = ['t', 't', 'u', 'r', 'l', 'e', 't'];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool showContinueButton = false; // 👈 Track when to show the button

  @override
  void initState() {
    super.initState();
    _playSound(); // Play the sound immediately when the screen is loaded
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
                      Image.asset('assets/images/turtle.png', height: 150),
                      SizedBox(height: 20),
                      // Word slots
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

                              // Check if the word is fully and correctly formed
                              Future.delayed(Duration(milliseconds: 300), () {
                                if (_isWordCorrect()) {
                                  _showCorrectBanner();
                                  setState(() {
                                    showContinueButton = true; // Show the button
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
                // Floating letters (only those not yet placed)
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
          // ✅ "Continue" Button at the Bottom (Visible if correct)
          if (showContinueButton)
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Turt()), // 👈 Navigate to MonkScreen
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