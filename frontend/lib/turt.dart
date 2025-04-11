import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'story.dart';

class Turt extends StatefulWidget {
  @override
  _TurtState createState() => _TurtState();
}

class _TurtState extends State<Turt> {
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  bool showMessage = false;
  int score = 0;
  bool isQuizFinished = false;
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);


  final List<Question> questions = [
    Question(
      image: "assets/images/t.png",
      options: [
        "assets/images/monk.png",
        "assets/images/fox.png",
        "assets/images/milk.png",
        "assets/images/turtle.png",
      ],
      correctAnswer: "assets/images/turtle.png",
      soundFile: "sounds/start_t.mp3",
      optionSounds: {
        "assets/images/monk.png": "sounds/monkey_m.mp3",
        "assets/images/fox.png": "sounds/fox_word.mp3",
        "assets/images/milk.png": "sounds/milk.mp3",
        "assets/images/turtle.png": "sounds/turtle.mp3",
      },
    ),
    Question(
      image: "assets/images/sound.png",
      options: [
        "assets/images/a.png",
        "assets/images/t.png",
        "assets/images/r.png",
        "assets/images/ff.png"
      ],
      correctAnswer: "assets/images/t.png",
      soundFile: "sounds/letter_turtle.mp3",
      optionSounds: {
        "assets/images/a.png": "sounds/ae.mp3",
        "assets/images/t.png": "sounds/ti.mp3",
        "assets/images/r.png": "sounds/are.mp3",
        "assets/images/ff.png": "sounds/ef.mp3",
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    playSound();
  }

  void playSound() async {
    await _audioPlayer.play(AssetSource(questions[currentQuestionIndex].soundFile));
  }

  void checkAnswer(String option) async {
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
            print("Moving to next question, index: $currentQuestionIndex");
            playSound(); // Play next question's sound
          });
        } else {
          setState(() {
            isQuizFinished = true;
          });
          // Automatically navigate to HomeScreen after a 2-second delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context); // This will navigate back to the HomeScreen
          });
        }
      });
    });
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
      appBar: AppBar(title: Text('Tap the Animal')),
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
