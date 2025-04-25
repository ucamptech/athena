import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MaterialApp(home: Scaffold(body: TriangleTracePage())));
}

class TriangleTracePage extends StatefulWidget {
  @override
  _TriangleTracePageState createState() => _TriangleTracePageState();
}

class _TriangleTracePageState extends State<TriangleTracePage>
    with SingleTickerProviderStateMixin {
  Path _trianglePath = Path();
  ui.PathMetric? _pathMetric;
  Offset? _arrowPos;
  double _arrowAngle = 0.0;
  double _tracedDistance = 0.0;
  bool _isCompleted = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createTrianglePath();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _createTrianglePath() {
    Size size = MediaQuery.of(context).size;
    Offset p1 = Offset(size.width / 2, size.height / 3);
    Offset p2 = Offset(size.width / 2 - 100, size.height / 3 + 200);
    Offset p3 = Offset(size.width / 2 + 100, size.height / 3 + 200);

    Path trianglePath = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    setState(() {
      _trianglePath = trianglePath;
      _pathMetric = _trianglePath.computeMetrics().first;
      _updateArrow(0.0);
    });
  }

  void _updateArrow(double distance) {
    if (_pathMetric == null) return;
    if (distance > _pathMetric!.length) distance = _pathMetric!.length;
    final tangent = _pathMetric!.getTangentForOffset(distance);
    if (tangent != null) {
      setState(() {
        _arrowPos = tangent.position;
        _arrowAngle = tangent.angle;
        _tracedDistance = distance;
        if (distance >= _pathMetric!.length - 1) {
          _isCompleted = true;
          _animationController.forward();
        }
      });
    }
  }

  double _calculateNearestDistance(Offset position) {
    if (_pathMetric == null) return 0.0;
    double closestDistance = 0.0;
    double minDistance = double.infinity;
    for (double d = 0.0; d <= _pathMetric!.length; d += 1.0) {
      final tangent = _pathMetric!.getTangentForOffset(d);
      if (tangent == null) continue;
      final dist = (position - tangent.position).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestDistance = d;
      }
    }
    return closestDistance;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final localPosition =
        (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
        final distance = _calculateNearestDistance(localPosition);
        _updateArrow(distance);
      },
      child: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: TriangleGuidePainter(
              trianglePath: _trianglePath,
              arrowPos: _arrowPos,
              arrowAngle: _arrowAngle,
              tracedDistance: _tracedDistance,
              isCompleted: _isCompleted,
            ),
          ),
          if (_isCompleted)
            Center(
              child: ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.5).animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.elasticOut)),
                child: Icon(Icons.check_circle, color: Colors.green, size: 100),
              ),
            )
        ],
      ),
    );
  }
}

class TriangleGuidePainter extends CustomPainter {
  final Path trianglePath;
  final Offset? arrowPos;
  final double arrowAngle;
  final double tracedDistance;
  final bool isCompleted;

  TriangleGuidePainter({
    required this.trianglePath,
    required this.arrowPos,
    required this.arrowAngle,
    required this.tracedDistance,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final tracedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    _drawDashedPath(canvas, trianglePath, dashedPaint);

    if (tracedDistance > 0.0) {
      final tracedPath = trianglePath.computeMetrics().first.extractPath(0.0, tracedDistance);
      canvas.drawPath(tracedPath, tracedPaint);
    }

    if (arrowPos != null && !isCompleted) {
      canvas.save();
      canvas.translate(arrowPos!.dx, arrowPos!.dy);
      canvas.rotate(arrowAngle);
      final arrowPath = Path()
        ..moveTo(-12, -12)
        ..lineTo(12, 0)
        ..lineTo(-12, 12)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = Colors.blueAccent);
      canvas.restore();
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 6.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extractPath = metric.extractPath(
            distance, next.clamp(0.0, metric.length));
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
