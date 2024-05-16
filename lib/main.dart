import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color ControLED',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ColorPickerScreen(),
      debugShowCheckedModeBanner: false, // Quitar el banner de depuración
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  final _controller = CircleColorPickerController(
    initialColor: Colors.blue,
  );

  Color selectedColor = Colors.blue; // Color inicial
  double redValue = 0.0;
  double greenValue = 0.0;
  double blueValue = 255.0;

  void connectToDevice() {
    // Implementa la lógica de conexión Bluetooth aquí
  }

  void sendColorToArduino(Color color) {
    // Convierte el color a valores RGB y envía los valores al Arduino mediante Bluetooth
  }

  void updateSelectedColor() {
    _controller.color = Color.fromARGB(
        255, redValue.toInt(), greenValue.toInt(), blueValue.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Color ControLED',
            style: TextStyle(fontSize: 18), // Reducir el tamaño del título
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CircleColorPicker(
                  controller: _controller,
                  onChanged: (color) {
                    setState(() {
                      selectedColor = color;
                      redValue = color.red.toDouble();
                      greenValue = color.green.toDouble();
                      blueValue = color.blue.toDouble();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ColorSlider(
                  label: 'Red',
                  value: redValue,
                  onChanged: (value) {
                    setState(() {
                      redValue = value;
                      updateSelectedColor();
                    });
                  },
                ),
                ColorSlider(
                  label: 'Green',
                  value: greenValue,
                  onChanged: (value) {
                    setState(() {
                      greenValue = value;
                      updateSelectedColor();
                    });
                  },
                ),
                ColorSlider(
                  label: 'Blue',
                  value: blueValue,
                  onChanged: (value) {
                    setState(() {
                      blueValue = value;
                      updateSelectedColor();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                connectToDevice(); // Conecta al Arduino
                sendColorToArduino(
                    selectedColor); // Envía el color seleccionado
              },
              child: const Text('Enviar color al Arduino'),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const ColorSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 255,
          divisions: 255,
        ),
      ],
    );
  }
}
