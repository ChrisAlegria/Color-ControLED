import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb_blue;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as fb_serial;
import 'package:color_control_led/Pages/color_picker_screen.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar Provider
import 'package:color_control_led/Pages/devices_screen.dart';
import 'package:color_control_led/Connections/bluetooth_connection.dart';

class BluetoothConnectionProvider extends StatefulWidget {
  final Widget child;

  const BluetoothConnectionProvider({Key? key, required this.child})
      : super(key: key);

  @override
  _BluetoothConnectionProviderState createState() =>
      _BluetoothConnectionProviderState();
}

class _BluetoothConnectionProviderState
    extends State<BluetoothConnectionProvider> {
  fb_serial.BluetoothDevice? _device;
  fb_serial.BluetoothConnection? _connection;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothConection(), // Crear el provider aquí
      child: widget.child,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  void _checkBluetoothState() {
    fb_blue.FlutterBlue.instance.state.listen((state) {
      setState(() {
        isBluetoothOn = state == fb_blue.BluetoothState.on;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return const ColorPickerScreen();
      case 2:
        return const DevicesScreen();
      default:
        return Container();
    }
  }

  Widget _buildHome() {
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
                'Con esta aplicación, podrás conectarte a un Arduino Uno con el cual podrás establecer una conexión vía Bluetooth. Además, dicho Arduino cuenta con un LED conectado mediante una protoboard. Con esta aplicación, podrás seleccionar un color y enviarlo al LED para que este lo reproduzca y visualizar diversos tipos de colores.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            label: 'Selector',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Conexión',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
