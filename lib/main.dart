import 'package:flutter/material.dart';
import 'package:flutter_tester/features/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      // The theme is defined here.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true, // Recommended for modern UI
      ),
      // The actual UI is in a separate widget.
      home: const HomePage(),
    );
  }
}