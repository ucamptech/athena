import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'two.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OneMonkeysScreen(),
    );
  }
}

class OneMonkeysScreen extends StatefulWidget {
  const OneMonkeysScreen({super.key});

  @override
  State<OneMonkeysScreen> createState() => _OneMonkeysScreenState();
}

class _OneMonkeysScreenState extends State<OneMonkeysScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioFinished = false; // Track if audio has finished

  @override
  void initState() {
    super.initState();
    _playSound();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isAudioFinished = true; // Mark audio as finished
      });
    });
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/one_monkey.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/two.png', // Replace with your image asset
                  height: 300,
                  width: 400,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Spacer(),
          if (_isAudioFinished)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child:
            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TwoMonkeysScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Icon(
                    Icons.arrow_forward, size: 40, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
