import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'turtle.dart';
import 'dart:convert';

class Monk extends StatefulWidget {
  @override
  _MonkState createState() => _MonkState();
}

class _MonkState extends State<Monk> {
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  bool showMessage = false;
  int score = 0;
  bool isQuizFinished = false;
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  final GameSession gameSession = GameSession(
    userID: 'user_123',
    loginDate: DateTime.now(),
  );

  late DateTime questionShownTime;

  final List<Question> questions = [
    Question(
      image: "assets/images/ff.png",
      options: [
        "assets/images/monk.png",
        "assets/images/turtle.png",
        "assets/images/fox.png",
        "assets/images/milk.png"
      ],
      correctAnswer: "assets/images/fox.png",
      soundFile: "sounds/letter_f.mp3",
      optionSounds: {
        "assets/images/monk.png": "sounds/monkey_m.mp3",
        "assets/images/turtle.png": "sounds/turtle.mp3",
        "assets/images/fox.png": "sounds/fox_word.mp3",
        "assets/images/milk.png": "sounds/milk.mp3",
      },
    ),
    Question(
      image: "assets/images/sound.png",
      options: [
        "assets/images/a.png",
        "assets/images/i.png",
        "assets/images/r.png",
        "assets/images/ff.png"
      ],
      correctAnswer: "assets/images/ff.png",
      soundFile: "sounds/start_fox.mp3",
      optionSounds: {
        "assets/images/a.png": "sounds/ae.mp3",
        "assets/images/i.png": "sounds/ii.mp3",
        "assets/images/r.png": "sounds/are.mp3",
        "assets/images/ff.png": "sounds/ef.mp3",
      },
    ),
    Question(
      image: "assets/images/fox.png",
      options: [
        "assets/images/moon.png",
        "assets/images/mouse.png",
        "assets/images/box.png",
        "assets/images/house.png"
      ],
      correctAnswer: "assets/images/box.png",
      soundFile: "sounds/fox.mp3",
      optionSounds: {
        "assets/images/moon.png": "sounds/moon.mp3",
        "assets/images/mouse.png": "sounds/mouse.mp3",
        "assets/images/box.png": "sounds/box.mp3",
        "assets/images/house.png": "sounds/house.mp3",
      },
    ),
    Question(
      image: "assets/images/ff.png",
      options: [
        "assets/images/fish.png",
        "assets/images/frog.png",
        "assets/images/fox.png",
        "assets/images/fan.png"
      ],
      correctAnswer: "assets/images/fox.png",
      soundFile: "sounds/things_f.mp3",
      optionSounds: {
        "assets/images/fish.png": "sounds/fish.mp3",
        "assets/images/frog.png": "sounds/frog.mp3",
        "assets/images/fox.png": "sounds/fox_word.mp3",
        "assets/images/fan.png": "sounds/fan.mp3",
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    playSound();
    questionShownTime = DateTime.now();
  }

  void playSound() async {
    await _audioPlayer.play(AssetSource(questions[currentQuestionIndex].soundFile));
  }

  void checkAnswer(String option) async {
    DateTime userAnswerTime = DateTime.now();
    print("Checking answer: $option");

    await _audioPlayer.stop(); // Stop any currently playing sound

    // Get sound file for the clicked image
    String? soundFile = questions[currentQuestionIndex].optionSounds[option];

    if (soundFile != null) {
      print("Playing sound for option: $soundFile");
      try {
        await _audioPlayer.setSource(AssetSource(soundFile)); // Load the audio file
        await _audioPlayer.resume(); // Play the sound
        print("Option sound played");
      } catch (e) {
        print("Error playing option sound: $e");
      }
    }

    setState(() {
      selectedAnswer = option;
      bool isCorrect = selectedAnswer == questions[currentQuestionIndex].correctAnswer;
      showMessage = true;

      // Determine the asset type (image or sound) based on the question
      String assetPath;
      if (questions[currentQuestionIndex].image.isNotEmpty) {
        assetPath = questions[currentQuestionIndex].image; // It's an image
      } else {
        assetPath = questions[currentQuestionIndex].soundFile; // It's a sound file
      }

      // Add to exercise result list
      gameSession.exerciseList.add(
      ExerciseResult(
      exerciseID: 'Q${currentQuestionIndex + 1}',
      assets: assetPath,
      result: isCorrect ? 'correct' : 'incorrect',
      timeActivityIsDisplayed: questionShownTime,
      timeUserIsActive: userAnswerTime,
      ),
      );

      if (isCorrect) gameSession.accumulatedSessionScore++;


      Future.delayed(const Duration(seconds: 1), () {
        if (isCorrect) {
          setState(() {
            score++;
          });
        }

        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = '';
            showMessage = false;
            questionShownTime = DateTime.now();
            print("Moving to next question, index: $currentQuestionIndex");
            playSound(); // Play next question's sound
          });
        } else {
          setState(() {
            isQuizFinished = true;
          });

          showSessionJson();
          // Automatically go back to the home screen after finishing the quiz
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context, true); // This will go back to the previous screen (home screen)
          });
        }
      });
    });
  }

  void showSessionJson() {
    String prettyJson = const JsonEncoder.withIndent('  ').convert(gameSession.toJson());
    print('📊 Game Session JSON (pretty):');
    print(prettyJson);
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = '';
      showMessage = false;
      score = 0;
      isQuizFinished = false;
      playSound();
    });
  }

  @override
  Widget build(BuildContext context) {

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Tap')),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 150),
                Image.asset(question.image, width: 100, height: 100),
                const SizedBox(height: 150),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      String option = question.options[index];
                      bool isSelected = selectedAnswer == option;
                      bool isCorrectChoice = isSelected && option == question.correctAnswer;
                      bool isIncorrectChoice = isSelected && option != question.correctAnswer;

                      return GestureDetector(
                        onTap: () => checkAnswer(option),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrectChoice ? Colors.green : Colors.red)
                                  : Colors.grey,
                              width: isSelected ? 4 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(option, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (showMessage)
                  if (selectedAnswer == question.correctAnswer)
                    Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.green[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Great job!",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
                          ),
                          Icon(Icons.flag_outlined, color: Colors.green[800]), // Flag icon for correct answer
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.red[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Incorrect!",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                          ),
                          Icon(Icons.flag_outlined, color: Colors.red[800]), // Flag icon for correct answer
                        ],
                      ),
                    )
              ]
          ),
        ),
      ),
    );
  }
}

// ==== Model Classes ====

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

// Question Model
class Question{
  final String image;
  final List<String> options;
  final String correctAnswer;
  final String soundFile;
  final Map<String, String> optionSounds;


  Question({
    required this.image,
    required this.options,
    required this.correctAnswer,
    required this.soundFile,
    required this.optionSounds,
  });
}
