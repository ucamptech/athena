import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:3000'; // Update this if needed

class QuestionScreen extends StatefulWidget {
  final String userID; // Add userID property

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

  // Corrected GameSession initialization
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
        print("API Response: $data");
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

  void playSound() {
    final question = questions[currentQuestionIndex];
    final audioUrl = question.questionAudio.startsWith('http')
        ? question.questionAudio // If it's already a full URL
        : '$baseUrl${question.questionAudio}'; // If it's a relative URL

    print("Playing audio from: $audioUrl");

    try {
      _audioPlayer.play(UrlSource(audioUrl, mimeType: 'audio/mpeg',));
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

    print("Playing selected answer audio from: $audioUrl");

    try {
      await _audioPlayer.play(UrlSource(audioUrl, mimeType: 'audio/mpeg',));
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

    await Future.delayed(const Duration(seconds: 0));

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isQuizFinished) {
      return Scaffold(
        body: Center(
          child: Text('Quiz Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    final List<Option> allOptions = [...question.options]..shuffle(Random(currentQuestionIndex));

    return Scaffold(
      appBar: AppBar(title: Text("Question ${currentQuestionIndex + 1}")),
      body: Column(
        children: [
          const SizedBox(height: 100),
          Text(question.question, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 300),
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
    return Option(
      id: json['choiceID'],
      imageUrl: '$baseUrl${json['image']}',
      name: json['name'],
      audioUrl: '$baseUrl${json['audio']}', // fixed URL
    );
  }
}

class Question {
  final String question;
  final String questionAudio;
  final List<Option> options;
  final Option correctAnswer;

  Question({
    required this.question,
    required this.questionAudio,
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
      // Constructing the correct URL, replacing any 'sounds/' with 'audio/'
      questionAudio: json['questionAudio'],
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

  // Method to log an individual attempt
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

  // Method to log the entire session's data
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

