import 'package:flutter/material.dart';
import 'dart:math'; // For random colors

class ColorChangerScreen extends StatefulWidget {
  const ColorChangerScreen({super.key});

  @override
  State<ColorChangerScreen> createState() => _ColorChangerScreenState();
}

class _ColorChangerScreenState extends State<ColorChangerScreen> {
  // Initial background color
  Color _backgroundColor = Colors.white;

  // Function to generate random color
  void _changeColor() {
    setState(() {
      _backgroundColor = Color.fromRGBO(
        Random().nextInt(256), // Red value
        Random().nextInt(256), // Green value
        Random().nextInt(256), // Blue value
        1, // Opacity
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: ElevatedButton(
          onPressed: _changeColor,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Change Color',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}