import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

Future<void> sendGameSessionToBackend(GameSession gameSession) async {
  final url = Uri.parse('https://api.com/submit');

  try {
    // Convert GameSession to JSON
    String jsonBody = jsonEncode(gameSession.toJson());

    // Send POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',  
      },
      body: jsonBody,
    );

    // Check the response from the server
    if (response.statusCode == 200) {
      print('Game session successfully sent to backend');
    } else {
      print('Failed to send game session. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending game session: $error');
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

// ==== Question Model ====

class Question {
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

// ==== Main Question Screen ====

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  bool showMessage = false;
  bool isQuizFinished = false;

  final GameSession gameSession = GameSession(
    userID: 'user_123',
    loginDate: DateTime.now(),
  );

  late DateTime questionShownTime;

  final List<Question> questions = [
    Question(
      image: "assets/images/m.png",
      options: [
        "assets/images/monkey.png.png",
        "assets/images/deer.png.png",
        "assets/images/giraffe.png.png",
        "assets/images/bear.png.png"
      ],
      correctAnswer: "assets/images/monkey.png.png",
      soundFile: "sounds/animal_m.mp3",
      optionSounds: {
        "assets/images/monkey.png.png": "sounds/monkey_m.mp3",
        "assets/images/deer.png.png": "sounds/deer_d.mp3",
        "assets/images/giraffe.png.png": "sounds/giraffe_g.mp3",
        "assets/images/bear.png.png": "sounds/bear_b.mp3",
      },
    ),
  Question(
  image: "assets/images/sound.png",
  options: [
  "assets/images/i.png",
  "assets/images/r.png",
  "assets/images/a.png",
  "assets/images/mm.png"
  ],
  correctAnswer: "assets/images/mm.png",
  soundFile: "sounds/letter_m.mp3",
  optionSounds: {
  "assets/images/i.png": "sounds/i.mp3",
  "assets/images/r.png": "sounds/r.mp3",
  "assets/images/a.png": "sounds/a.mp3",
  "assets/images/mm.png": "sounds/m.mp3",
  },
  ),
  Question(
  image: "assets/images/monk.png",
  options: [
  "assets/images/mm.png",
  "assets/images/i.png",
  "assets/images/r.png",
  "assets/images/a.png"
  ],
  correctAnswer: "assets/images/mm.png",
  soundFile: "sounds/monk.mp3",
  optionSounds: {
  "assets/images/mm.png": "sounds/em.mp3",
  "assets/images/i.png": "sounds/ii.mp3",
  "assets/images/r.png": "sounds/are.mp3",
  "assets/images/a.png": "sounds/ae.mp3",
  },
  ),
  Question(
  image: "assets/images/mm.png",
  options: [
  "assets/images/milk.png",
  "assets/images/mouse.png",
  "assets/images/monk.png",
  "assets/images/moon.png"
  ],
  correctAnswer: "assets/images/monk.png",
  soundFile: "sounds/start.mp3",
  optionSounds: {
  "assets/images/milk.png": "sounds/milk.mp3",
  "assets/images/mouse.png": "sounds/mouse.mp3",
  "assets/images/monk.png": "sounds/monkey_m.mp3",
  "assets/images/moon.png": "sounds/moon.mp3",
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
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(questions[currentQuestionIndex].soundFile));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void checkAnswer(String option) async {
    DateTime userAnswerTime = DateTime.now();
    await _audioPlayer.stop();

    String? soundFile = questions[currentQuestionIndex].optionSounds[option];
    if (soundFile != null) {
      try {
        await _audioPlayer.setSource(AssetSource(soundFile));
        await _audioPlayer.resume();
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
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = '';
            showMessage = false;
            questionShownTime = DateTime.now();
            playSound();
          });
        } else {
          setState(() {
            isQuizFinished = true;
          });
          // Send the game session to the backend
          sendGameSessionToBackend(gameSession);
          showSessionJson();
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context, true);
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

  double getProgress() {
    return (currentQuestionIndex + 1) / questions.length;
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: getProgress(),
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: selectedAnswer == question.correctAnswer ? Colors.green[100] : Colors.red[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedAnswer == question.correctAnswer ? "Great job!" : "Incorrect!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedAnswer == question.correctAnswer ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                          Icon(Icons.flag_outlined, color: selectedAnswer == question.correctAnswer ? Colors.green[800] : Colors.red[800]),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
