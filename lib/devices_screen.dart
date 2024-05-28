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
  final fb_blue.FlutterBlue _flutterBlue = fb_blue.FlutterBlue.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  bool _showDevices = false;
  bool _isScanning = false;
  bool _showScanResults = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  List<fb_blue.ScanResult> _scanResults = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });
  }

  Future<void> _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() {
      _devices = res;
      _showDevices = true;
      _showScanResults = false;
    });
  }

  void _scanDevices() {
    if (_isScanning) {
      _flutterBlue.stopScan();
      setState(() {
        _isScanning = false;
        _showScanResults = false;
      });
    } else {
      _flutterBlue.startScan(timeout: const Duration(seconds: 4));
      _flutterBlue.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
          _isScanning = true;
          _showScanResults = true;
          _showDevices = false;
        });
      });
    }
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
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
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
          if (_bluetoothState) ...[
            _infoDevice(),
            _scanDevicesButton(),
            Expanded(
              child: _showDevices || _showScanResults
                  ? _listDevices()
                  : const SizedBox.shrink(),
            ),
            _buttons(),
          ],
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
                      _getDevices();
                    });
                  },
                  child: const Text("Desconectar"),
                )
              : TextButton(
                  onPressed: () {
                    if (_showDevices) {
                      setState(() {
                        _showDevices = false;
                      });
                    } else {
                      if (_isScanning) {
                        _scanDevices();
                      }
                      _getDevices();
                    }
                  },
                  child: Text(_showDevices
                      ? "Ocultar dispositivos"
                      : "Ver dispositivos"),
                ),
        ),
      ],
    );
  }

  Widget _scanDevicesButton() {
    return ListTile(
      tileColor: Colors.black12,
      trailing: TextButton(
        onPressed: _bluetoothState
            ? () {
                if (_isScanning) {
                  _scanDevices();
                } else {
                  if (_showDevices) {
                    setState(() {
                      _showDevices = false;
                    });
                  }
                  _scanDevices();
                }
              }
            : null,
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
                  if (_showDevices)
                    ..._devices.map((device) => ListTile(
                          title: Text(device.name ?? device.address),
                          trailing: TextButton(
                            child: const Text('Conectar'),
                            onPressed: _bluetoothState
                                ? () async {
                                    setState(() => _isConnecting = true);

                                    _connection =
                                        await BluetoothConnection.toAddress(
                                            device.address);
                                    _deviceConnected = device;
                                    setState(() {
                                      _devices = [];
                                      _isConnecting = false;
                                      _showDevices = false;
                                    });

                                    _receiveData();
                                  }
                                : null,
                          ),
                        )),
                  if (_showScanResults)
                    ..._scanResults.map((result) => ListTile(
                          title: Text(result.device.name.isNotEmpty
                              ? result.device.name
                              : "Unknown Device"),
                          subtitle: Text(result.device.id.toString()),
                          trailing: TextButton(
                            child: const Text('Conectar'),
                            onPressed: _bluetoothState
                                ? () async {
                                    setState(() => _isConnecting = true);

                                    _connection =
                                        await BluetoothConnection.toAddress(
                                            result.device.id.toString());
                                    _deviceConnected =
                                        result.device as BluetoothDevice;
                                    setState(() {
                                      _scanResults = [];
                                      _isConnecting = false;
                                      _showScanResults = false;
                                    });

                                    _receiveData();
                                  }
                                : null,
                          ),
                        )),
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
                  onTap: _bluetoothState ? () => _sendData("1") : null,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ActionButton(
                  color: Colors.red,
                  text: "Apagar",
                  onTap: _bluetoothState ? () => _sendData("0") : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
