import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const PuzzleApp());

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzlePage(),
    );
  }
}

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final List<String> allPieces =
  List.generate(9, (i) => 'assets/puzzle/${i + 1}.png');

  List<String?> board = List.filled(9, null);
  List<String> availablePieces = [];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    board = List.filled(9, null);
    availablePieces = List.from(allPieces)..shuffle(Random());
    setState(() {});
  }

  bool _isCompleted() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] != allPieces[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pieceSize = MediaQuery.of(context).size.width / 3 - 30;

    return Scaffold(
      appBar: AppBar(title: const Text('🧩 Jigsaw Puzzle')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (_isCompleted())
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                '🎉 Puzzle Completed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final piece = board[index];
                return DragTarget<String>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    setState(() {
                      board[index] = data;
                      availablePieces.remove(data);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? Colors.blue
                              : Colors.black26,
                          width: 2,
                        ),
                      ),
                      child: piece != null
                          ? Image.asset(piece, fit: BoxFit.cover)
                          : const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          const Text('Drag Pieces Below'),
          Expanded(
            flex: 1,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availablePieces.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final piece = availablePieces[index];
                return Draggable<String>(
                  data: piece,
                  feedback: Image.asset(piece, width: pieceSize, height: pieceSize),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(piece),
                  ),
                  child: Image.asset(piece),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text("Reset Puzzle"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
