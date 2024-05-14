import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ColorPickerPage(),
      debugShowCheckedModeBanner: false, // Eliminacion de banner
    );
  }
}

class ColorPickerPage extends StatefulWidget {
  @override
  _ColorPickerPageState createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color ControLED'),
      ),
      body: Center(
        child: ColorWheel(
          onColorSelected: (color) {
            setState(() {
              selectedColor = color;
            });
          },
          selectedColor: selectedColor,
        ),
      ),
    );
  }
}

class ColorWheel extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color selectedColor;

  ColorWheel({required this.onColorSelected, required this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double wheelSize = constraints.maxWidth * 0.8;
        double selectedCircleSize = wheelSize * 0.5;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: wheelSize,
              height: wheelSize,
              child: GestureDetector(
                onPanUpdate: (details) {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  var localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  var dx = localPosition.dx - wheelSize / 2;
                  var dy = localPosition.dy - wheelSize / 2;
                  var angle = atan2(dy, dx);
                  var hue = angle < 0 ? angle / (2 * pi) + 1 : angle / (2 * pi);
                  var color =
                      HSVColor.fromAHSV(1.0, hue * 360, 1.0, 1.0).toColor();
                  onColorSelected(color);
                },
                child: CustomPaint(
                  painter: ColorWheelPainter(selectedColor: selectedColor),
                ),
              ),
            ),
            Positioned(
              child: Container(
                width: selectedCircleSize,
                height: selectedCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor,
                ),
              ),
            ),
            Positioned(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  '${selectedColor.toHex()}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

extension ColorExtension on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2, 8)}';
  }
}

class ColorWheelPainter extends CustomPainter {
  final Color selectedColor;

  ColorWheelPainter({required this.selectedColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 4.0;
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (int i = 0; i < 360; i++) {
      final double hue = i.toDouble();
      final Paint paint = Paint()
        ..color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor()
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final double x1 =
          centerX + (radius - strokeWidth / 2) * cos(i * pi / 180);
      final double y1 =
          centerY + (radius - strokeWidth / 2) * sin(i * pi / 180);
      final double x2 =
          centerX + (radius + strokeWidth / 2) * cos(i * pi / 180);
      final double y2 =
          centerY + (radius + strokeWidth / 2) * sin(i * pi / 180);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
