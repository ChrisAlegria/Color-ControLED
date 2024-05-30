import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothConection with ChangeNotifier {
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;

  bool get isBluetoothOn => _bluetoothState;
  bool get isConnecting => _isConnecting;
  BluetoothConnection? get connection => _connection;
  BluetoothDevice? get deviceConnected => _deviceConnected;
  List<BluetoothDevice> get devices => _devices;

  BluetoothConection() {
    _init();
  }

  void _init() {
    _requestPermission();
    _restoreConnectedDevice();

    bluetooth.state.then((state) {
      _bluetoothState = state.isEnabled;
      notifyListeners();
    });

    bluetooth.onStateChanged().listen((state) {
      _bluetoothState = state.isEnabled;
      notifyListeners();
    });
  }

  Future<void> _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  Future<void> _saveConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    if (_deviceConnected != null) {
      await prefs.setString(
          'connected_device', jsonEncode(_deviceConnected!.toMap()));
    } else {
      await prefs.remove('connected_device');
    }
  }

  Future<void> _restoreConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deviceJson = prefs.getString('connected_device');
    if (deviceJson != null) {
      _deviceConnected = BluetoothDevice.fromMap(jsonDecode(deviceJson));
      notifyListeners();
      _reconnectDevice(_deviceConnected!);
    }
  }

  Future<void> _reconnectDevice(BluetoothDevice device) async {
    _isConnecting = true;
    notifyListeners();
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _deviceConnected = device;
      _receiveData();
    } catch (e) {
      print('Could not reconnect: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void getDevices() async {
    var res = await bluetooth.getBondedDevices();
    _devices = res;
    notifyListeners();
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      if (String.fromCharCode(event[0]) == "p") {
        times += 1;
        notifyListeners();
      }
    });
  }

  void sendColor(Color color) async {
    if (_connection?.isConnected ?? false) {
      int red = color.red;
      int green = color.green;
      int blue = color.blue;

      String data = '$red,$green,$blue\n';
      _connection?.output.add(ascii.encode(data));
      await _connection?.output.allSent;
      print("Data sent: $data");
    } else {
      print("Connection is not established.");
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    _isConnecting = true;
    notifyListeners();
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _deviceConnected = device;
      _devices = [];
      _receiveData();
      await _saveConnectedDevice();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void disconnect() async {
    await _connection?.finish();
    _deviceConnected = null;
    await _saveConnectedDevice();
    notifyListeners();
  }
}
