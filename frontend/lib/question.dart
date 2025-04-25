import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:3000'; // Update this if needed

class QuestionScreen extends StatefulWidget {
  final String userID;

  const QuestionScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool isQuizFinished = false;
  bool showMessage = false;
  String selectedAnswerId = '';
  late DateTime questionShownTime;
  late GameSession gameSession;

  @override
  void initState() {
    super.initState();
    gameSession = GameSession(userID: widget.userID, loginDate: DateTime.now());
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/question-set'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          questions = data.map((json) => Question.fromJson(json)).toList();
          questionShownTime = DateTime.now();
          isLoading = false;
        });
        playSound();
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void playSound() async {
    final question = questions[currentQuestionIndex];
    final audioUrl = question.questionAudio.startsWith('http')
        ? question.questionAudio
        : '$baseUrl${question.questionAudio}';

    try {
      await _audioPlayer
          .play(UrlSource(audioUrl, mimeType: 'audio/mpeg'))
          .timeout(Duration(seconds: 60));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void handleAnswer(Option selectedOption) async {
    final current = questions[currentQuestionIndex];
    final timeTaken = DateTime.now().difference(questionShownTime);
    final isCorrect = selectedOption.id == current.correctAnswer.id;

    setState(() {
      selectedAnswerId = selectedOption.id;
      showMessage = true;
    });
    await _audioPlayer.stop();

    final audioUrl = selectedOption.audioUrl.startsWith('http')
        ? selectedOption.audioUrl
        : '$baseUrl${selectedOption.audioUrl}';

    try {
      await _audioPlayer.play(UrlSource(audioUrl, mimeType: 'audio/mpeg'));
    } catch (e) {
      print("Error playing selected answer audio: $e");
    }

    gameSession.addAttempt(
      selectedOption: selectedOption.name,
      correctAnswer: current.correctAnswer.name,
      timeTaken: timeTaken,
      isCorrect: isCorrect,
    );

    gameSession.logSession();

    await Future.delayed(const Duration(seconds: 2));

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerId = '';
        showMessage = false;
        questionShownTime = DateTime.now();
      });
      playSound();
    } else {
      setState(() {
        isQuizFinished = true;
      });
    }
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswerId = '';
      showMessage = false;
      isQuizFinished = false;
      gameSession = GameSession(userID: widget.userID, loginDate: DateTime.now());
      questionShownTime = DateTime.now();
    });

    playSound();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isQuizFinished) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    }

    final question = questions[currentQuestionIndex];
    final List<Option> allOptions = [...question.options]..shuffle(Random(currentQuestionIndex));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Question ${currentQuestionIndex + 1}",
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'ComicSans',
                ),
              ),
            ),
            const SizedBox(height: 50),
            if (question.questionImage.isNotEmpty)
              Image.network(
                question.questionImage,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            const SizedBox(height: 80),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: allOptions.map((option) {
                  final isSelected = selectedAnswerId == option.id;
                  final isCorrect = option.id == question.correctAnswer.id;
                  final isWrong = isSelected && !isCorrect;

                  return GestureDetector(
                    onTap: showMessage ? null : () => handleAnswer(option),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green
                              : isWrong
                              ? Colors.red
                              : Colors.transparent,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(option.imageUrl, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Option {
  final String id;
  final String imageUrl;
  final String name;
  final String audioUrl;

  Option({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.audioUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'];
    if (!imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl$imageUrl';
    }

    String audioUrl = json['audio'];
    if (!audioUrl.startsWith('http')) {
      audioUrl = '$baseUrl$audioUrl';
    }

    return Option(
      id: json['choiceID'],
      imageUrl: imageUrl,
      name: json['name'],
      audioUrl: audioUrl,
    );
  }
}

class Question {
  final String question;
  final String questionAudio;
  final String questionImage;
  final List<Option> options;
  final Option correctAnswer;

  Question({
    required this.question,
    required this.questionAudio,
    required this.questionImage,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List)
        .map((opt) => Option.fromJson(opt))
        .toList();
    final correct = Option.fromJson(json['correctAnswer'][0]);

    return Question(
      question: json['question'],
      questionAudio: json['questionAudio'],
      questionImage: '$baseUrl${json['questionImage']}',
      options: [...options, correct],
      correctAnswer: correct,
    );
  }
}

class GameSession {
  final String userID;
  final DateTime loginDate;
  final List<Map<String, dynamic>> questionAttempts = [];

  GameSession({required this.userID, required this.loginDate});

  void addAttempt({
    required String selectedOption,
    required String correctAnswer,
    required Duration timeTaken,
    required bool isCorrect,
  }) {
    questionAttempts.add({
      'selectedOption': selectedOption,
      'correctAnswer': correctAnswer,
      'timeTakenMs': timeTaken.inMilliseconds,
      'isCorrect': isCorrect,
    });
  }

  void logSession() {
    print("GameSession for User: $userID");
    print("Login Date: $loginDate");
    for (var attempt in questionAttempts) {
      print("Attempt:");
      print("  Selected Option: ${attempt['selectedOption']}");
      print("  Correct Answer: ${attempt['correctAnswer']}");
      print("  Time Taken (ms): ${attempt['timeTakenMs']}");
      print("  Is Correct: ${attempt['isCorrect']}");
    }
  }
}
