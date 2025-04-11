import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

//Include Sound Screen
class SoundScreen extends StatefulWidget {
  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  int currentSoundIndex = 0;
  String selectedAnswer = '';
  bool showMessage = false;
  int score = 0;
  bool isQuizFinished = false;
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  final List<Sound> sounds = [
    Sound(
      soundImage: "assets/images/sound.png",
      options: [
        "assets/images/monkey.png.png",
        "assets/images/deer.png.png",
        "assets/images/giraffe.png.png",
        "assets/images/bear.png.png"
      ],
      correctAnswer: "assets/images/monkey.png.png",
      soundFile: "monkey.mp3",
    ),
    Sound(
      soundImage: "assets/images/sound.png",
      options: [
        "assets/images/deer.png.png",
        "assets/images/giraffe.png.png",
        "assets/images/bear.png.png",
        "assets/images/monkey.png.png"
      ],
      correctAnswer: "assets/images/giraffe.png.png",
      soundFile: "giraffe.mp3",
    ),
    Sound(
      soundImage: "assets/images/sound.png",
      options: [
        "assets/images/giraffe.png.png",
        "assets/images/deer.png.png",
        "assets/images/monkey.png.png",
        "assets/images/bear.png.png"
      ],
      correctAnswer: "assets/images/bear.png.png",
      soundFile: "bear.mp3",
    ),
  ];

  @override
  void initState() {
    super.initState();
    playCurrentSound();
  }

  void playCurrentSound() async {
    try {
      await _audioPlayer.stop(); // Stop any existing sound
      await _audioPlayer.play(AssetSource("sounds/${sounds[currentSoundIndex].soundFile}"));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }


  void checkAnswer(String option) {
    setState(() {
      selectedAnswer = option;
      bool isCorrect = selectedAnswer == sounds[currentSoundIndex].correctAnswer;
      showMessage = true;

      if (isCorrect) {
        score++;
        Future.delayed(const Duration(seconds: 1), () {
          if (currentSoundIndex < sounds.length - 1) {
            setState(() {
              currentSoundIndex++;
              selectedAnswer = '';
              showMessage = false;
            });
            playCurrentSound(); // Play the next sound
          } else {
            setState(() {
              isQuizFinished = true;
            });
          }
        });
      }
    });
  }

  void restartQuiz() {
    setState(() {
      currentSoundIndex = 0;
      selectedAnswer = '';
      showMessage = false;
      score = 0;
      isQuizFinished = false;
    });
    playCurrentSound(); // Restart with the first sound
  }

  @override
  Widget build(BuildContext context) {
    if (isQuizFinished) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Nice Hearing! 🎉",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Your Score: $score / ${sounds.length}",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: restartQuiz,
                child: const Text("Restart Game?"),
              ),
            ],
          ),
        ),
      );
    }

    final sound = sounds[currentSoundIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Tap the Animal")),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image.asset(sound.soundImage, width: 100, height: 100),
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
                  itemCount: sound.options.length,
                  itemBuilder: (context, index) {
                    String option = sound.options[index];
                    bool isSelected = selectedAnswer == option;
                    bool isCorrectChoice = isSelected && option == sound.correctAnswer;
                    bool isIncorrectChoice = isSelected && option != sound.correctAnswer;

                    return GestureDetector(
                      onTap: () => checkAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isCorrectChoice ? Colors.green : Colors.red)
                                : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(option, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (showMessage)
                Text(
                  selectedAnswer == sound.correctAnswer ? "Correct! 🎉" : "Try Again ❌",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: selectedAnswer == sound.correctAnswer ? Colors.green : Colors.red,
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
class Sound {
  final String soundImage;
  final List<String> options;
  final String correctAnswer;
  final String soundFile;

  Sound({
    required this.soundImage,
    required this.options,
    required this.correctAnswer,
    required this.soundFile,
  });
}