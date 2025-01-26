import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Colors.green;
  static const Color accentColor = Colors.white;

  static TextStyle headerTextStyle = const TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
