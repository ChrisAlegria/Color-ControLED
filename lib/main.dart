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
  // ignore: library_private_types_in_public_api
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  // BluetoothDevice? selectedDevice;

  final _controller = CircleColorPickerController(
    initialColor: Colors.blue,
  );

  Color selectedColor = Colors.blue; // Color inicial
  double redValue = 0.0;
  double greenValue = 0.0;
  double blueValue = 255.0;

  void connectToDevice() {
    // Implementa la lógica de conexión Bluetooth aquí
    // Escanea los dispositivos disponibles y conecta al deseado
    // Configura las características para la comunicación
  }

  void sendColorToArduino(Color color) {
    // Convierte el color a valores RGB
    // int red = color.red;
    // int green = color.green;
    // int blue = color.blue;

    // Envía los valores RGB al Arduino mediante Bluetooth
    // Implementa tu protocolo de comunicación específico
  }

  void updateSelectedColor() {
    // Calcula el color combinado usando los valores de los sliders
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
            CircleColorPicker(
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
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ColorSlider(
                  label: 'Red',
                  value: redValue,
                  activeColor: Colors.red,
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
                  activeColor: Colors.green,
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
                  activeColor: Colors.blue,
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
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const ColorSlider({
    super.key,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
          min: 0,
          max: 255,
          divisions: 255,
        ),
      ],
    );
  }
}
