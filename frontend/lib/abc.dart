import 'package:flutter/material.dart';
import 'dart:ui';
//Include TraceScreen
class AlphabetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Letter")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 26,
        itemBuilder: (context, index) {
          String letter = String.fromCharCode(65 + index);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TraceScreen(letter: letter)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TraceScreen extends StatefulWidget {
  final String letter;
  TraceScreen({required this.letter});

  @override
  _TraceScreenState createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  List<Offset?> points = [];
  Color brushColor = Colors.red;
  double brushSize = 8.0;

  Map<String, List<Offset>> letterPaths = {
    "A": [Offset(100, 400), Offset(200, 100), Offset(300, 400)],
    "B": [Offset(100, 100), Offset(100, 400), Offset(200, 250)],
  };

  bool isTraceCorrect() {
    List<Offset> reference = letterPaths[widget.letter] ?? [];
    if (reference.isEmpty || points.isEmpty) return false;

    double tolerance = 20.0;

    for (int i = 0; i < reference.length; i++) {
      if (i >= points.length || points[i] == null) return false;

      double dx = (reference[i].dx - points[i]!.dx).abs();
      double dy = (reference[i].dy - points[i]!.dy).abs();

      if (dx > tolerance || dy > tolerance) {
        return false;
      }
    }
    return true;
  }

  void _checkTracing() {
    bool correct = isTraceCorrect();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(correct ? "Great Job!" : "Try Again"),
        content: Text(correct ? "Your tracing is correct!" : "Your tracing doesn't match. Try again."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trace ${widget.letter}")),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Text(
                widget.letter,
                style: TextStyle(fontSize: 300, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox box = context.findRenderObject() as RenderBox;
                points.add(box.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
            child: CustomPaint(
              painter: TracePainter(points, brushColor, brushSize),
              size: Size.infinite,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                points.clear();
              });
            },
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: _checkTracing,
          ),
        ],
      ),
    );
  }
}

class TracePainter extends CustomPainter {
  final List<Offset?> points;
  final Color brushColor;
  final double brushSize;
  TracePainter(this.points, this.brushColor, this.brushSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = brushColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushSize;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}