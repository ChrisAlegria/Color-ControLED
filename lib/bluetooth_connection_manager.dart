import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothConnectionManager extends InheritedWidget {
  final BluetoothDevice? device;
  final BluetoothConnection? connection;
  final ValueChanged<BluetoothDevice?> onDeviceChanged;
  final ValueChanged<BluetoothConnection?> onConnectionChanged;

  const BluetoothConnectionManager({
    Key? key,
    required this.device,
    required this.connection,
    required this.onDeviceChanged,
    required this.onConnectionChanged,
    required Widget child,
  }) : super(key: key, child: child);

  static BluetoothConnectionManager? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BluetoothConnectionManager>();
  }

  @override
  bool updateShouldNotify(BluetoothConnectionManager old) {
    return device != old.device || connection != old.connection;
  }
}
