import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:color_control_led/Pages/home.dart';
import 'package:color_control_led/Connections/bluetooth_connection.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothConection()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Color ControLED",
      initialRoute: 'Home',
      routes: {
        'Home': (context) => const MainPage(),
      },
    );
  }
}
