import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'color_picker_screen.dart';
import 'package:color_control_led/bluetooth_status_screen.dart';

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
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  void _checkBluetoothState() {
    FlutterBlue.instance.state.listen((state) {
      setState(() {
        isBluetoothOn = state == BluetoothState.on;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color ControLED'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Bienvenido a Color ControLED',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Con esta aplicación, podrás conectarte a un Arduino Uno con el cual podras establecer una conexion via bluetooth, el cual ademas dicho Arduino cuenta con un LED conectado mediante una protoboard. Por lo que con esta aplicacion podrás seleccionar un color y enviarlo al LED para que este lo reproduzca y de esta manera visualizar diversos tipos de colores.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isBluetoothOn
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ColorPickerScreen()),
                      );
                    }
                  : null,
              child: const Text('Seleccionar Color'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FlutterBlueApp()),
                );
              },
              child: const Text('Conectar Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
