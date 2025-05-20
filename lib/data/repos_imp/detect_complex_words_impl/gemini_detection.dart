import 'dart:convert';
import 'package:Transcripto/core/constants/api_keys.dart';
import 'package:Transcripto/core/utils/word_level_heper.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/domain/repos/detect_complex_words_repo.dart';
import 'package:http/http.dart' as http;

class GeminiDetection implements DetectComplexWordsRepo {
  final String _model = 'gemini-1.5-pro';

  @override
  Future<ResponseModel?> getComplexWordsByText(
    String transcript,
    String level,
    String toLanguage,
    String fromLanguage,
  ) async {
    print('transcript is $transcript');
    print('level is $level');
    print('to learn language is $toLanguage');
    print('from language is $fromLanguage');
    print('prompting gemini ...');
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$GEMINI_API_KEY';

    final jsonPath =
        toLanguage.toLowerCase() == 'french'
            ? 'assets/words/french_words_cefr_real.json'
            : toLanguage.toLowerCase() == 'spanish'
            ? 'assets/words/spanish_words_cefr_all_levels.json'
            : 'assets/words/arabic_words_cefr.json';

    final filteredWords = await WordFilter.filterWordsByLevel(
      transcript: transcript,
      userLevel: level,
      jsonPath: jsonPath,
    );

    print('filtered words $filteredWords');

    try {
      final prompt = '''
      Given a list of complex words in $toLanguage, generate a JSON response containing detailed information for each word. 

      
      Input:
      - user's native language: $fromLanguage
      - the language the user is learning: $toLanguage
      - Words: ${jsonEncode(filteredWords)}
      
      For each word in Words , provide:
      - The word itself in $toLanguage .
      - The word type (e.g., noun, verb, adjective) in $fromLanguage.
      - The translation of the word into $fromLanguage.
      - A simple explanation of the word type and its meaning in $fromLanguage.
      - Three example sentences using the word in $toLanguage, each with its translation in $fromLanguage.

      The response must be a valid JSON array, with each element following this structure:
      [
        {
          "word": "<Complex word in $toLanguage>",
          "wordType": "<Type of word, in $fromLanguage (e.g., اسم, فعل, صفة)>",
          "wordTranslated": "<Translation of the word in $fromLanguage>",
          "wordExplanation": "<Word type and simple explanation in $fromLanguage>",
          "examples": [
            {
              "sentence": "<Example sentence using the word in $toLanguage>",
              "translation": "<Translation of the sentence in $fromLanguage>"
            },
            {
              "sentence": "<Example sentence using the word in $toLanguage>",
              "translation": "<Translation of the sentence in $fromLanguage>"
            },
            {
              "sentence": "<Example sentence using the word in $toLanguage>",
              "translation": "<Translation of the sentence in $fromLanguage>"
            }
          ]
        },
      ]


      make sure the list contains ${filteredWords.length} as the given words , for each word do what you are asked above


      Return the response as a valid JSON string that is to be decoded to an array. Ensure all text fields (word, wordType, wordTranslated, wordExplanation, sentence, translation) are properly escaped and valid for JSON. If a word is not directly translatable, retain the original word and note it in the explanation. Use natural and accurate $fromLanguage for all fields requiring $fromLanguage, and ensure example sentences are grammatically correct and contextually appropriate.
          
    - DO NOT return markdown or wrap the JSON in any code block.
    - make sure to not return any other special charachters that can be obstacles for using jsonDecode in dart , because your response will be passed to jsonDecode.
    - Ensure the number of complex words matches the level-based percentage.
    - Translations must be accurate and natural for learners.
      ''';

      final requestBodyTwo = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {"temperature": 0.3, "maxOutputTokens": 2048},
      };

      try {
        print(
          'promt and words based on your level ${filteredWords.length} ...',
        );
        final responseTwo = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBodyTwo),
        );

        if (responseTwo.statusCode == 200) {
          final responseBodyTwo = jsonDecode(responseTwo.body);
          print('prompt success and data is $responseBodyTwo');

          final contentTwo =
              responseBodyTwo['candidates']?[0]?['content']?['parts']?[0]?['text'];

          if (contentTwo == null || contentTwo.isEmpty) {
            throw Exception("Empty or missing content from Gemini response");
          }

          final cleanedContentTwo = cleanJsonResponse(contentTwo);
          final complexWordsWithTranslation = jsonDecode(cleanedContentTwo);

          List<ComplexWord> complexWords = [];
          for (var word in complexWordsWithTranslation) {
            complexWords.add(ComplexWord.fromJson(word));
          }

          print('returned successfully');
          return ResponseModel(
            contextOfText: 'contextOfText',
            contextOfTextTranslated: 'contextOfTextTranslated',
            complexWordsWithExamples: complexWords,
          );
        } else {
          print('request 2 failed.');
          return null;
        }
      } catch (e) {
        rethrow;
      }

      // final prompt = '''

      //     You are a language learning assistant.

      //     I will provide a list of words in $toLanguage. For each word, return detailed metadata in the following **strict JSON format**. The user is a native speaker of **$fromLanguage** and is learning **$toLanguage**.

      //     here is the list of the words $wordsBasedOnUsersLevel

      //     The JSON structure for each word must include:
      //     - "word": the original $toLanguage word
      //     - "wordType": the part of speech (noun, verb, adjective, etc.) — written in **$fromLanguage**
      //     - "wordTranslated": the translation of the word into **$fromLanguage**
      //     - "wordExplanation": a short and simple explanation of the word (definition + type), in **$toLanguage**
      //     - "examples": an array of **3** example sentences that:
      //       - use the word in **$toLanguage**
      //       - include a "translation" field with the sentence translated into **$fromLanguage**

      //       your output should be something like this :

      //       [
      //         {
      //           "word": "<Complex word in $toLanguage>",
      //           "wordType": "<Type of word, in $fromLanguage (e.g., noun, verb)>",
      //           "wordTranslated": "<Translation of the word in $fromLanguage>",
      //           "wordExplanation": "<Word type and simple explanation in $toLanguage>",
      //           "examples": [
      //             {
      //               "sentence": "<Example sentence using the word in $toLanguage>",
      //               "translation": "<Translation of the sentence in $fromLanguage>"
      //             },
      //             {
      //               "sentence": "<Example sentence using the word in $toLanguage>",
      //               "translation": "<Translation of the sentence in $fromLanguage>"
      //             },
      //             {
      //               "sentence": "<Example sentence using the word in $toLanguage>",
      //               "translation": "<Translation of the sentence in $fromLanguage>"
      //             }
      //           ]
      //         }
      //         // Repeat for all the other words
      //       ]

      //     Return only the JSON array (no markdown, no additional comments, no intro or outro).

      // ''';
    } catch (e) {
      print("Gemini HTTP Error: $e");
      return null;
    }
  }

  List<String> cleanListOfWords(List<String> words) {
    return words.toSet().toList().where((word) => word.length > 3).toList();
  }

  String cleanJsonResponse(String raw) {
    print('Cleaning JSON...');
    return raw.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  bool _validateResponse(Map<String, dynamic> json) {
    print('Validating structure...');
    if (!json.containsKey('contextOfText') ||
        !json.containsKey('contextOfTextTranslated') ||
        !json.containsKey('complexWordsWithExamples')) {
      return false;
    }

    final examples = json['complexWordsWithExamples'];
    if (examples is! List) return false;

    for (final word in examples) {
      if (!(word is Map)) return false;
      if (!word.containsKey('word') ||
          !word.containsKey('wordTranslated') ||
          !word.containsKey('wordExplanation') ||
          !word.containsKey('examples'))
        return false;

      final wordExamples = word['examples'];
      if (wordExamples is! List || wordExamples.length != 3) return false;

      for (final example in wordExamples) {
        if (!example.containsKey('sentence') ||
            !example.containsKey('translation')) {
          return false;
        }
      }
    }

    print('Validation successful.');
    return true;
  }
}
