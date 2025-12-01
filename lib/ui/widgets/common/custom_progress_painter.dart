import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;
  final bool showPercentage;

  CircularProgressPainter({
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.strokeWidth = 8.0,
    this.showPercentage = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw percentage text
    if (showPercentage) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(progress * 100).toInt()}%',
          style: TextStyle(
            color: progressColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Custom painter for linear progress bar with gradient
class LinearProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final double height;
  final double borderRadius;

  LinearProgressPainter({
    required this.progress,
    this.gradientColors = const [Colors.blue, Colors.cyan],
    this.backgroundColor = Colors.grey,
    this.height = 8.0,
    this.borderRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Draw background
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(rect, backgroundPaint);

    // Draw progress
    if (progress > 0) {
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, size.height),
        Radius.circular(borderRadius),
      );

      final gradient = LinearGradient(
        colors: gradientColors,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );

      canvas.drawRRect(progressRect, progressPaint);
    }
  }

  @override
  bool shouldRepaint(LinearProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
}

/// Custom painter for pie chart
class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double strokeWidth;

  PieChartPainter({
    required this.data,
    this.colors = const [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ],
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -math.pi / 2; // Start from top

    int colorIndex = 0;
    for (final entry in data.entries) {
      final sweepAngle = 2 * math.pi * (entry.value / total);

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw stroke
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

