import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Define the CEFR level hierarchy
const Map<String, int> cefrOrder = {
  'A1': 1,
  'A2': 2,
  'B1': 3,
  'B2': 4,
  'C1': 5,
  'C2': 6,
};

// Model for a word and its CEFR level
class WordLevel {
  final String word;
  final String level;

  WordLevel({required this.word, required this.level});

  factory WordLevel.fromJson(Map<String, dynamic> json) {
    return WordLevel(
      word: json['word'] as String,
      level: json['level'] as String,
    );
  }
}

class WordFilter {
  // Load JSON file from assets
  static Future<List<WordLevel>> loadWordLevels(String jsonPath) async {
    final String jsonString = await rootBundle.loadString(jsonPath);
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((json) => WordLevel.fromJson(json)).toList();
  }

  // Filter words from transcript with CEFR level higher than user's level
  static Future<List<String>> filterWordsByLevel({
    required String transcript,
    required String userLevel,
    required String jsonPath,
  }) async {
    // Validate user level
    final userLevelValue = cefrOrder[userLevel.toUpperCase()];
    if (userLevelValue == null) {
      throw Exception(
        'Invalid CEFR level: $userLevel. Valid levels are: ${cefrOrder.keys.join(', ')}',
      );
    }

    // Load word levels from JSON
    final wordLevels = await loadWordLevels(jsonPath);

    print('loaded words ${wordLevels.first.word}');

    // Create a map for quick lookup
    final wordLevelMap = {
      for (var entry in wordLevels)
        entry.word.toLowerCase(): entry.level.toUpperCase(),
    };

    // Split transcript into words
    final transcriptWords = transcript.toLowerCase().split(' ');

    print('transcript words are ${transcript.length} word');

    // Filter words with higher CEFR level
    final higherLevelWords = <String>{}; // Using Set to avoid duplicates
    for (var word in transcriptWords) {
      if (word.length > 4) {
        // Remove basic punctuation
        word = word.replaceAll(RegExp('[.,!?;:"\'()]'), '');
        if (wordLevelMap.containsKey(word.toLowerCase())) {
          final wordLevel = wordLevelMap[word]!;
          if (cefrOrder[wordLevel]! >= userLevelValue) {
            print('$word added');
            higherLevelWords.add(word);
          }
        }
      }
    }

    print('words to prompt $higherLevelWords');

    return higherLevelWords.toList();
  }
}
