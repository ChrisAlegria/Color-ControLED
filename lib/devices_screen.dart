import 'dart:convert';
import 'package:color_control_led/widgets/action_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb_blue;

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  final fb_blue.FlutterBlue _flutterBlue =
      fb_blue.FlutterBlue.instance; // Instancia de FlutterBlue
  bool _bluetoothState = false;
  bool _isConnecting = false;
  bool _showDevices =
      false; // Variable para controlar la visibilidad de la lista de dispositivos
  bool _isScanning =
      false; // Variable para controlar el escaneo de dispositivos
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  List<fb_blue.ScanResult> _scanResults =
      []; // Lista para almacenar los resultados del escaneo
  BluetoothDevice? _deviceConnected;
  int times = 0;

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() {
      _devices = res;
      _showDevices = true; // Mostrar la lista de dispositivos
    });
  }

  void _toggleDeviceList() {
    setState(() {
      _showDevices = !_showDevices;
      if (_showDevices) {
        _getDevices();
      }
    });
  }

  void _scanDevices() {
    if (_isScanning) {
      _flutterBlue.stopScan();
    } else {
      _flutterBlue.startScan(timeout: Duration(seconds: 4));
      _flutterBlue.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
      });
    }
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      if (String.fromCharCodes(event) == "p") {
        setState(() => times = times + 1);
      }
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Conexión Bluetooth'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _controlBT(),
          _infoDevice(),
          _scanDevicesButton(), // Agrega el botón de buscar dispositivos
          Expanded(child: _showDevices ? _listDevices() : SizedBox.shrink()),
          _buttons(), // Mover los controles a la parte inferior
        ],
      ),
    );
  }

  Widget _controlBT() {
    return SwitchListTile(
      value: _bluetoothState,
      onChanged: (bool value) async {
        if (value) {
          await _bluetooth.requestEnable();
        } else {
          await _bluetooth.requestDisable();
        }
      },
      tileColor: Colors.black26,
      title: Text(
        _bluetoothState ? "Bluetooth encendido" : "Bluetooth apagado",
      ),
    );
  }

  Widget _infoDevice() {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.black12,
          title: Text("Conectado a: ${_deviceConnected?.name ?? "ninguno"}"),
          trailing: _connection?.isConnected ?? false
              ? TextButton(
                  onPressed: () async {
                    await _connection?.finish();
                    setState(() {
                      _deviceConnected = null;
                      _getDevices(); // Mostrar la lista de dispositivos al desconectar
                    });
                  },
                  child: const Text("Desconectar"),
                )
              : TextButton(
                  onPressed: _toggleDeviceList,
                  child: Text(_showDevices
                      ? "Ocultar dispositivos"
                      : "Ver dispositivos"), // Cambiar el texto según el estado
                ),
        ),
      ],
    );
  }

  Widget _scanDevicesButton() {
    return ListTile(
      tileColor: Colors.black12,
      trailing: TextButton(
        onPressed: _scanDevices,
        child: Text(_isScanning ? "Detener búsqueda" : "Buscar dispositivos"),
      ),
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  for (final device in _devices)
                    ListTile(
                      title: Text(device.name ?? device.address),
                      trailing: TextButton(
                        child: const Text('Conectar'),
                        onPressed: () async {
                          setState(() => _isConnecting = true);

                          _connection = await BluetoothConnection.toAddress(
                              device.address);
                          _deviceConnected = device;
                          _devices = [];
                          _isConnecting = false;

                          _receiveData();

                          setState(() {
                            _showDevices =
                                false; // Ocultar la lista de dispositivos al conectar
                          });
                        },
                      ),
                    ),
                  for (final result in _scanResults)
                    ListTile(
                      title: Text(result.device.name.isNotEmpty
                          ? result.device.name
                          : "Unknown Device"),
                      subtitle: Text(result.device.id.toString()),
                      trailing: TextButton(
                        child: const Text('Conectar'),
                        onPressed: () async {
                          setState(() => _isConnecting = true);

                          _connection = await BluetoothConnection.toAddress(
                              result.device.id.toString());
                          _deviceConnected = result.device as BluetoothDevice;
                          _scanResults = [];
                          _isConnecting = false;

                          _receiveData();

                          setState(() {
                            _showDevices =
                                false; // Ocultar la lista de dispositivos al conectar
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buttons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      color: Colors.black12,
      child: Column(
        children: [
          const Text('Controles para LED', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: "Encender",
                  color: Colors.green,
                  onTap: () => _sendData("1"),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ActionButton(
                  color: Colors.red,
                  text: "Apagar",
                  onTap: () => _sendData("0"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
