import 'package:duolingo/letter.dart';
import 'package:duolingo/turtle.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'abc.dart';
import 'question.dart';
import 'story.dart';

class HomeScreen extends StatefulWidget {
  final String userID; // Added userID field

  // Constructor to accept userID
  const HomeScreen({Key? key, required this.userID}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> buttonUnlocked = [true, false, false, false];

  void navigateTo(BuildContext context, Widget screen, int index) {
    if (!buttonUnlocked[index]) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((value) {
      if (value == true && index + 1 < buttonUnlocked.length) {
        setState(() {
          buttonUnlocked[index + 1] = true; // Unlock the next button
        });
      }
    });
  }

  Widget buildGoldButton(IconData icon, VoidCallback onTap, bool unlocked) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.3,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget buildDot() {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amberAccent,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalLine() {
    return Column(
      children: [
        buildDot(),
        buildDot(),
        buildDot(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backs.jpg'), // Make sure this exists
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Book Icon
              Positioned(
                top: 120,
                child: Column(
                  children: [
                    buildGoldButton(Icons.menu_book,
                            () => navigateTo(context, MadMonkeysScreen(), 3), buttonUnlocked[3]),
                  ],
                ),
              ),

              // Dots between Book and Turtle
              Positioned(
                top: 200,
                child: buildVerticalLine(),
              ),

              // Turtle Icon
              Positioned(
                bottom: 550,
                child: Column(
                  children: [
                    buildGoldButton(Icons.volume_up,
                            () => navigateTo(context, TurtleGameScreen(), 2), buttonUnlocked[2]),
                  ],
                ),
              ),

              // Dots between Turtle and ABC
              Positioned(
                bottom: 470,
                child: buildVerticalLine(),
              ),

              // ABC Icon
              Positioned(
                bottom: 270,
                child: Column(
                  children: [
                    buildGoldButton(Icons.abc,
                            () => navigateTo(context, LetterGameScreen(), 1), buttonUnlocked[1]),
                  ],
                ),
              ),

              // Dots between ABC and Star
              Positioned(
                bottom: 190,
                child: buildVerticalLine(),
              ),

              // Star Icon (First level)
              Positioned(
                bottom: 100,
                child: buildGoldButton(Icons.star,
                        () => navigateTo(context, QuestionScreen(userID: widget.userID), 0), buttonUnlocked[0]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
