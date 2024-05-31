import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as fb_serial;
import 'package:flutter_blue/flutter_blue.dart' as fb_blue;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:color_control_led/Connections/bluetooth_connection.dart';
import 'package:color_control_led/widgets/action_button.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final fb_serial.FlutterBluetoothSerial _bluetooth =
      fb_serial.FlutterBluetoothSerial.instance;
  final fb_blue.FlutterBlue _flutterBlue = fb_blue.FlutterBlue.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  bool _showDevices = false;
  bool _isScanning = false;
  bool _showScanResults = false;
  fb_serial.BluetoothConnection? _connection;
  List<fb_serial.BluetoothDevice> _devices = [];
  List<fb_blue.ScanResult> _scanResults = [];
  fb_serial.BluetoothDevice? _deviceConnected;
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

  void _showConnectedSnackBar(String deviceName) {
    final snackBar = SnackBar(
      content: Text('Conectado a $deviceName'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            Navigator.pop(context,
                {'device': _deviceConnected, 'connection': _connection});
          },
        ),
      ),
      body: Column(
        children: [
          _controlBT(),
          if (!_bluetoothState)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 200.0,
                      color: const Color.fromARGB(137, 48, 48, 48),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'El Bluetooth se encuentra ${_bluetoothState ? 'habilitado' : 'deshabilitado'}.',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          if (_bluetoothState) ...[
            _infoDevice(),
            _scanDevicesButton(),
            Expanded(
              child: _showDevices || _showScanResults
                  ? _listDevices()
                  : const SizedBox.shrink(),
            ),
            _buttons(BluetoothConection())
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
        : Container(
            color: Colors.grey.shade100, // Color de fondo de toda la lista
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_showDevices)
                    Container(
                      color: Colors
                          .white, // Color de fondo de la sección de dispositivos
                      child: Column(
                        children: _devices
                            .map((device) => ListTile(
                                  title: Text(device.name ?? device.address),
                                  trailing: TextButton(
                                    child: const Text('Conectar'),
                                    onPressed: _bluetoothState
                                        ? () async {
                                            setState(
                                                () => _isConnecting = true);

                                            _connection = await fb_serial
                                                    .BluetoothConnection
                                                .toAddress(device.address);
                                            _deviceConnected = device;
                                            setState(() {
                                              _scanResults = [];
                                              _isConnecting = false;
                                              _showScanResults = false;
                                            });
                                            _receiveData();
                                            _showConnectedSnackBar(
                                                device.name ?? device.address);
                                          }
                                        : null,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  if (_showScanResults)
                    Container(
                      color: Colors
                          .white, // Color de fondo de la sección de resultados de escaneo
                      child: Column(
                        children: _scanResults
                            .map((result) => ListTile(
                                  title: Text(result.device.name.isNotEmpty
                                      ? result.device.name
                                      : "Unknown Device"),
                                  subtitle: Text(result.device.id.toString()),
                                  trailing: TextButton(
                                    child: const Text('Conectar'),
                                    onPressed: _bluetoothState
                                        ? () async {
                                            setState(
                                                () => _isConnecting = true);

                                            _connection = await fb_serial
                                                    .BluetoothConnection
                                                .toAddress(result.device.id
                                                    .toString());
                                            _deviceConnected = result.device
                                                as fb_serial.BluetoothDevice;
                                            setState(() {
                                              _scanResults = [];
                                              _isConnecting = false;
                                              _showScanResults = false;
                                            });

                                            _receiveData();
                                            Navigator.pop(context, {
                                              'device': _deviceConnected,
                                              'connection': _connection
                                            });
                                          }
                                        : null,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buttons(BluetoothConection bluetoothConnection) {
    bool _isOn = false;
    Color _buttonColor = Colors.red;
    String _buttonText = 'OFF';

    void _toggleState() {
      setState(() {
        _isOn = !_isOn;
        _buttonColor = _isOn ? Colors.blue : Colors.red;
        _buttonText = _isOn ? 'ON' : 'OFF';
        // Envía el comando correspondiente al estado del botón
        if (_isOn) {
          bluetoothConnection
              .sendColor(Colors.white); // Encender el dispositivo
          _sendData("1"); // Envía el comando para encender el dispositivo
        } else {
          bluetoothConnection.sendColor(Colors.black); // Apagar el dispositivo
          _sendData("0"); // Envía el comando para apagar el dispositivo
        }
      });
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 60.0, // Ancho del contenedor
            height: 60.0, // Alto del contenedor
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Forma circular
              color: Colors.white, // Fondo blanco para el icono
            ),
            child: IconButton(
              icon: const Icon(Icons.power_settings_new),
              color: _buttonColor,
              iconSize: 40.0, // Tamaño del icono más pequeño
              onPressed: _toggleState,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            _buttonText,
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  void _showConnectionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Conexión establecida"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
