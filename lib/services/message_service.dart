import 'package:flutter/services.dart';
import 'dart:math';

class HappyMessageService {
  static Future<String> getRandomHappyMessage([String language = 'pl']) async {
    try {
      final messages = await getAllMessages(language);
      if (messages.isNotEmpty) {
        final random = Random();
        return messages[random.nextInt(messages.length)];
      }
      return _getDefaultMessage(language);
    } catch (e) {
      return _getDefaultMessage(language);
    }
  }

  static Future<String> getMessageByIndex(int index, [String language = 'pl']) async {
    try {
      final messages = await getAllMessages(language);
      if (messages.isNotEmpty && index >= 0 && index < messages.length) {
        return messages[index];
      }
      return _getDefaultMessage(language);
    } catch (e) {
      return _getDefaultMessage(language);
    }
  }

  static Future<List<String>> getAllMessages([String language = 'pl']) async {
    try {
      final String response = await rootBundle.loadString('assets/behappy text.csv');
      final lines = response.split('\n');
      
      if (lines.length < 2) return [_getDefaultMessage(language)];
      
      // Mapowanie języków do kolumn
      final languageMap = {
        'pl': 0,  // Polski
        'en': 1,  // Angielski
        'de': 2,  // Niemiecki
        'es': 3,  // Hiszpański
        'it': 4,  // Włoski
        'zh': 5,  // Chiński
      };
      
      final columnIndex = languageMap[language] ?? 0;
      final messages = <String>[];
      
      // Pomiń nagłówek (pierwsza linia)
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isNotEmpty) {
          final columns = line.split(';');
          if (columns.length > columnIndex) {
            final message = columns[columnIndex].trim();
            if (message.isNotEmpty) {
              messages.add(message);
            }
          }
        }
      }
      
      return messages.isNotEmpty ? messages : [_getDefaultMessage(language)];
    } catch (e) {
      return [_getDefaultMessage(language)];
    }
  }

  static String _getDefaultMessage(String language) {
    final defaultMessages = {
      'pl': 'Chce być szczęśliwy',
      'en': 'I Want to Be Happy',
      'de': 'Ich möchte glücklich sein',
      'es': 'Quiero ser feliz',
      'it': 'Voglio essere felice',
      'zh': '我想要快樂',
    };
    return defaultMessages[language] ?? 'Chce być szczęśliwy';
  }
}
