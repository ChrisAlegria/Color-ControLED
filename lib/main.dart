import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color ControLED',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ColorPickerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({Key? key}) : super(key: key);

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  final _controller = CircleColorPickerController(
    initialColor: Colors.blue,
  );

  Color selectedColor = Colors.blue;
  double redValue = 0.0;
  double greenValue = 0.0;
  double blueValue = 255.0;

  void connectToDevice() {
    // Implementa la lógica de conexión Bluetooth aquí
    // Escanea los dispositivos disponibles y conecta al deseado
    // Configura las características para la comunicación
  }

  bool sendColorToArduino(Color color) {
    try {
      // Convierte el color a valores RGB y envía los valores al Arduino mediante Bluetooth
      // Implementa tu protocolo de comunicación específico
      // Supongamos que esta función devuelve true si el envío fue exitoso y false en caso de error
      return true;
    } catch (e) {
      // Manejo de errores
      return false;
    }
  }

  void updateSelectedColor() {
    _controller.color = Color.fromARGB(
      255,
      redValue.toInt(),
      greenValue.toInt(),
      blueValue.toInt(),
    );
  }

  String getColorName(Color color) {
    if (color == Colors.red) return "Rojo";
    if (color == Colors.green) return "Verde";
    if (color == Colors.blue) return "Azul";
    // Agrega más colores si es necesario
    return "personalizado";
  }

  void showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: [
              _buildColorBox(selectedColor),
              const SizedBox(width: 10),
              Flexible(child: Text(message)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorBox(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Color ControLED',
            style: TextStyle(fontSize: 18),
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
                connectToDevice();
                bool success = sendColorToArduino(selectedColor);

                if (success) {
                  String colorName = getColorName(selectedColor);
                  String colorHex =
                      '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                  showMessageDialog(
                    context,
                    "Color Enviado",
                    "El color seleccionado es $colorHex  y se está reproduciendo en el LED en este momento.",
                  );
                } else {
                  showMessageDialog(context, "Error",
                      "Error: No se ha podido encender el LED.");
                }
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
    Key? key,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  }) : super(key: key);

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
