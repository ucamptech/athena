import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

const String baseUrl = 'http://10.0.2.2:3000'; // Adjust as needed

class LetterGameScreen extends StatefulWidget {
  final String userID;

  const LetterGameScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<LetterGameScreen> createState() => _LetterGameScreenState();
}

class _LetterGameScreenState extends State<LetterGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isLoading = true;
  bool showMessage = false;
  bool isCompleted = false;

  List<String> availableLetters = [];
  List<String?> placedLetters = [];
  Map<String, Color> letterColors = {};


  DateTime questionShownTime = DateTime.now();
  DateTime userActiveStartTime = DateTime.now();

  LetterGameData? letterGameData;

  @override
  void initState() {
    super.initState();
    fetchLetterGameData();
    questionShownTime = DateTime.now();
    userActiveStartTime = DateTime.now();
  }

  Future<void> fetchLetterGameData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/question-set'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If the API returns a list of questions, filter for 'letter' type
        final List<dynamic> questions = data is List ? data : [data];
        final letterQuestions = questions.where((q) => q['questionType'] == 'letter').toList();

        if (letterQuestions.isEmpty) {
          throw Exception('No letter-type questions found.');
        }

        // Pick the first one (or modify logic as needed)
        final loadedData = LetterGameData.fromJson(letterQuestions.first);

        setState(() {
          letterGameData = loadedData;
          placedLetters = List.filled(loadedData.letters.length, null);
          availableLetters = [...loadedData.letters]..shuffle();

          // Assign random color for each letter
          letterColors = {
            for (var letter in availableLetters) letter: _getRandomColor()
          };

          isLoading = false;
        });

        _playSound(loadedData.audioUrl);
      } else {
        print('Server responded with ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load letter game data');
      }
    } catch (e) {
      print('Error loading letter game data: $e');
    }
  }


  void _playSound(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Audio error: $e');
    }
  }

  void _checkCompletion() async {
    if (placedLetters.contains(null)) return; // Don't check if not complete

    final correctWord = letterGameData!.letters.join();
    final userWord = placedLetters.map((e) => e ?? '').join();

    final timeTaken = DateTime.now().difference(questionShownTime);
    final activeDuration = DateTime.now().difference(userActiveStartTime);

    if (userWord == correctWord) {
      setState(() {
        isCompleted = true;
        showMessage = true;
      });

      print("Correct! Time: ${timeTaken.inSeconds}s, Active time: ${activeDuration.inSeconds}s");

      await Future.delayed(Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        showMessage = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading || letterGameData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wordLength = letterGameData!.letters.length;

    return Scaffold(
      appBar: AppBar(title: Text("Build the Word")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            letterGameData!.imageUrl,
            height: 150,
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(wordLength, (index) {
              final placedLetter = placedLetters[index];
              final color = placedLetter != null ? letterColors[placedLetter] ?? Colors.black : Colors.black;

              return DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                    ),
                    child: Text(
                      placedLetter ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                },
                onAccept: (letter) {
                  setState(() {
                    placedLetters[index] = letter;
                    availableLetters.remove(letter);
                  });
                  _checkCompletion();
                },
              );
            }),
          ),

          SizedBox(height: 30),
          Wrap(
            spacing: 12,
            children: availableLetters.map((letter) {
              final color = letterColors[letter] ?? Colors.black;

              return Draggable<String>(
                data: letter,
                feedback: Material(
                  color: Colors.transparent,
                  child: Text(
                    letter,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Text(
                    letter,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          if (showMessage)
            Text(
              isCompleted ? '🎉 Correct!' : '❌ Try Again',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.red),
            ),
        ],
      ),
    );
  }
}

Color _getRandomColor() {
  final random = Random();
  return Colors.primaries[random.nextInt(Colors.primaries.length)];
}


class LetterGameData {
  final List<String> letters;
  final String imageUrl;
  final String audioUrl;

  LetterGameData({
    required this.letters,
    required this.imageUrl,
    required this.audioUrl,
  });

  factory LetterGameData.fromJson(Map<String, dynamic> json) {
    return LetterGameData(
      letters: List<String>.from(json['letters']),
      imageUrl: json['questionImage'].startsWith('http')
          ? json['questionImage']
          : '$baseUrl${json['questionImage']}',
      audioUrl: json['questionAudio'].startsWith('http')
          ? json['questionAudio']
          : '$baseUrl${json['questionAudio']}',
    );
  }
}
