import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'find_devices_screen.dart';

class BluetoothStatusScreen extends StatelessWidget {
  const BluetoothStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Status'),
      ),
      body: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return const FindDevicesScreen();
          } else {
            return BluetoothOffScreen(state: state);
          }
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothState? state;

  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.black54,
          ),
          Text(
            'Bluetooth está ${state != null ? state.toString().substring(15) : 'no disponible'}.',
          ),
          ElevatedButton(
            onPressed: () {
              _openBluetoothSettings(context);
            },
            child: const Text('Encender Bluetooth'),
          ),
        ],
      ),
    );
  }

  void _openBluetoothSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Bluetooth'),
          content: const Text(
              'Por favor, enciende el Bluetooth desde la configuración del dispositivo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
