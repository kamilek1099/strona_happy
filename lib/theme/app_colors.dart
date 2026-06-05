import 'package:flutter/material.dart';

class AppColors {
  static Color _darkenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).round(),
      (color.green * (1 - amount)).round(),
      (color.blue * (1 - amount)).round(),
    );
  }

  static const Map<String, Map<String, Color>> colorSchemes = {
    'cherryblossom': {
      'text': Color(0xFFB85A7A),
      'button': Color(0xFFFFE5F0),
      'background': Color(0xFFFFF5FA),
    },
    'coconut': {
      'text': Color(0xFF8B6B4A),
      'button': Color(0xFFE8D5B8),
      'background': Color(0xFFF5F0E8),
    },
    'mangoyellow': {
      'text': Color(0xFFCC8F3A),
      'button': Color(0xFFFFE8B0),
      'background': Color(0xFFFFF8E0),
    },
    'oceanblue': {
      'text': Color(0xFF4A7BA5),
      'button': Color(0xFFA8D0E8),
      'background': Color(0xFFD8E8F0),
    },
    'tropicalforest2': {
      'text': Color(0xFF1B4D2E),
      'button': Color(0xFFB8D4C0),
      'background': Color(0xFFE8F0EC),
    },
    'jasminetea': {
      'text': Color(0xFFA8956A),
      'button': Color(0xFFFAF0E3),
      'background': Color(0xFFFFFEF8),
    },
    'matchagreen': {
      'text': Color(0xFF6B8B5A),
      'button': Color(0xFFD8E8D0),
      'background': Color(0xFFF5FAF0),
    },
    'lavendersoft': {
      'text': Color(0xFF6B5B8B),
      'button': Color(0xFFDDD5EE),
      'background': Color(0xFFF6F4FA),
    },
  };
}
