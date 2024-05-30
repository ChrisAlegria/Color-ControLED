import 'package:flutter/material.dart';
import 'package:color_control_led/Pages/home.dart'; // Importa tu pantalla principal

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
      home: const MainPage(), // Usa tu pantalla principal aquí
      debugShowCheckedModeBanner: false,
    );
  }
}
