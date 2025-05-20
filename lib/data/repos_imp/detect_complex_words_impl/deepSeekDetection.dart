import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:Transcripto/core/constants/api_keys.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/domain/repos/detect_complex_words_repo.dart';

class DeepseekDetection implements DetectComplexWordsRepo {
  http.Client _client;
  final Logger _logger;

  DeepseekDetection({http.Client? client, Logger? logger})
    : _client = client ?? http.Client(),
      _logger = logger ?? Logger();

  // Configuration for word count ranges per CEFR level
  static const Map<String, Map<String, int>> _levelWordRanges = {
    'A1': {'minWords': 35, 'maxWords': 45},
    'A2': {'minWords': 35, 'maxWords': 45},
    'B1': {'minWords': 25, 'maxWords': 35},
    'B2': {'minWords': 20, 'maxWords': 30},
    'C1': {'minWords': 10, 'maxWords': 20},
    'C2': {'minWords': 5, 'maxWords': 8},
  };

  @override
  Future<ResponseModel> getComplexWordsByText(
    String transcript,
    String level,
    String toLanguage,
    String fromLanguage,
  ) async {
    try {
      _logger.d('Processing transcript: $transcript');
      _logger.d('Level: $level, To: $toLanguage, From: $fromLanguage');

      final words =
          transcript
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map(
                (w) => w
                    .replaceAll('.', 'replace')
                    .replaceAll(',', '')
                    .replaceAll('!', '')
                    .replaceAll('?', ''),
              )
              .toList();
      final wordsNumber = words.length;
      final uniqueWords = words.toSet().length; // Count unique words

      // Get word count range for the level
      final levelUpper = level.toUpperCase();
      final wordRange =
          _levelWordRanges[levelUpper] ?? {'minWords': 25, 'maxWords': 35};
      final minWords = wordRange['minWords']! * (uniqueWords / 200);
      final maxWords = wordRange['maxWords']! * (uniqueWords / 200);

      // Calculate target word count (random within range, capped by unique words)
      final targetWordCount =
          Random().nextInt(maxWords.toInt() - minWords.toInt() + 1) +
          minWords.toInt();

      _logger.d(
        'Transcript word count: $wordsNumber, Unique words: $uniqueWords, Target words: $targetWordCount',
      );

      final prompt = _buildPrompt(
        transcript: transcript,
        wordsNumber: wordsNumber,
        targetWordCount: targetWordCount.toInt(),
        level: levelUpper,
        toLanguage: toLanguage,
        fromLanguage: fromLanguage,
      );

      _client = http.Client();

      final response = await _client.post(
        Uri.parse(DEEPSEEK_BASE_URL),
        headers: {
          'Authorization': 'Bearer $DEEPSEEK_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a language assistant helping users improve their vocabulary.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens':
              8000, // Set the maximum number of tokens for the response
        }),
      );

      if (response.statusCode != 200) {
        throw DeepseekApiException(
          'API request failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['choices']?.isEmpty ?? true) {
        throw DeepseekApiException('Empty choices in API response');
      }

      final content = data['choices'][0]['message']['content'] as String;
      _logger.d('Raw API response: $content');

      final cleanedContent = _cleanJsonResponse(content);
      _logger.d('Cleaned JSON: $cleanedContent');

      final parsedJson = await _parseJsonSafely(cleanedContent);

      // if (!_validateResponse(parsedJson, targetWordCount.toInt())) {
      //   throw DeepseekResponseValidationException('Invalid response structure');
      // }

      final responseModel = ResponseModel.fromJson(parsedJson);
      _logger.i(
        'Successfully processed complex words: ${responseModel.complexWordsWithExamples.length} words',
      );
      return responseModel;
    } on FormatException catch (e) {
      _logger.e('JSON parsing error: $e');
      throw DeepseekResponseValidationException(
        'Failed to parse API response: $e',
      );
    } on http.ClientException catch (e) {
      _logger.e('Network error: $e');
      throw DeepseekApiException('Network error: $e');
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw DeepseekException('Unexpected error: $e');
    } finally {
      if (_client != http.Client()) {
        _client.close();
      }
    }
  }

  String _buildPrompt({
    required String transcript,
    required int wordsNumber,
    required int targetWordCount,
    required String level,
    required String toLanguage,
    required String fromLanguage,
  }) {
    return '''
You are an intelligent assistant that helps language learners expand their vocabulary through real-life video content.

**Transcript** (in $toLanguage):
"$transcript"

**Transcript Details**:
- Word count: $wordsNumber

**User Details**:
- Native Language: $fromLanguage
- Target Language: $toLanguage
- Proficiency Level: "$level" (CEFR scale: A1, A2, B1, B2, C1, C2)

**Task**:
1. Analyze the transcript and summarize its context in $toLanguage.
2. Extract exactly $targetWordCount unique complex words challenging for a "$level" learner.
   - Focus on less frequent, topic-specific, or idiomatic words.
   - If fewer than $targetWordCount complex words are found, supplement with random words suitable for the "$level" level to reach exactly $targetWordCount words.
   - Do not exceed $targetWordCount words under any circumstances.
3. Return a single JSON object in this strict format:

{
  "contextOfText": "<Summary in $toLanguage>",
  "contextOfTextTranslated": "<Translation of summary in $fromLanguage>",
  "complexWordsWithExamples": [
    {
      "word": "<Complex word in $toLanguage>",
      "wordType": "<Type in $fromLanguage (e.g., noun, verb)>",
      "wordTranslated": "<Translation in $fromLanguage>",
      "wordExplanation": "<Explanation in $toLanguage>",
      "examples": [
        {"sentence": "<Sentence in $toLanguage>", "translation": "<Translation in $fromLanguage>"},
        {"sentence": "<Sentence in $toLanguage>", "translation": "<Translation in $fromLanguage>"},
        {"sentence": "<Sentence in $toLanguage>", "translation": "<Translation in $fromLanguage>"}
      ]
    }
  ]
}

**Rules**:
- The JSON object must contain the keys: contextOfText, contextOfTextTranslated, and complexWordsWithExamples.
- Make sure to return a complete JSON object with no additional text.
- The JSON object must be valid and parsable.
- Return exactly $targetWordCount complex words in the complexWordsWithExamples array.
- Each word must have exactly 3 example sentences.
- Translations must be accurate and natural.
- Return a single JSON object with no markdown, code fences, or any explanatory text outside the JSON structure.
- If the transcript is empty or lacks complex words, return $targetWordCount random words suitable for the "$level" level.
''';
  }

  String _cleanJsonResponse(String raw) {
    _logger.d('Attempting to clean raw response: $raw');

    // Step 1: Check for empty or null input
    if (raw.isEmpty) {
      _logger.e('Input is empty');
      throw DeepseekResponseValidationException('Input is empty');
    }

    // Step 2: Remove markdown code fences and trim
    String cleaned =
        raw
            .replaceAll(RegExp(r'^```json\s*|\s*```$', multiLine: true), '')
            .trim();

    _logger.d('After removing fences: $cleaned');

    // Step 3: Find the outermost valid JSON object using brace matching
    int braceCount = 0;
    int bracketCount = 0;
    int startIndex = -1;
    int endIndex = -1;
    bool inString = false;
    String? lastUnterminatedString;

    for (int i = 0; i < cleaned.length; i++) {
      if (cleaned[i] == '"' && (i == 0 || cleaned[i - 1] != '\\')) {
        inString = !inString;
        if (!inString) {
          lastUnterminatedString = null;
        } else {
          lastUnterminatedString = cleaned.substring(i);
        }
      } else if (!inString) {
        if (cleaned[i] == '{') {
          if (braceCount == 0) {
            startIndex = i;
          }
          braceCount++;
        } else if (cleaned[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            endIndex = i;
            break;
          }
        } else if (cleaned[i] == '[') {
          bracketCount++;
        } else if (cleaned[i] == ']') {
          bracketCount--;
        }
      }
    }

    _logger.d(
      'Brace matching: startIndex=$startIndex, endIndex=$endIndex, braceCount=$braceCount, bracketCount=$bracketCount, inString=$inString',
    );

    if (startIndex == -1) {
      _logger.e('No JSON object found in response: $cleaned');
      throw DeepseekResponseValidationException('No JSON object found');
    }

    if (endIndex == -1 || startIndex >= endIndex) {
      _logger.w('Incomplete JSON detected, attempting to repair');
      cleaned = cleaned.substring(startIndex);

      // Fix unterminated string if present
      if (inString && lastUnterminatedString != null) {
        _logger.d('Fixing unterminated string: $lastUnterminatedString');
        cleaned =
            '${cleaned.substring(0, cleaned.length - lastUnterminatedString.length)}"';
      }

      // Append closing brackets and braces
      if (bracketCount > 0) {
        cleaned += ']' * bracketCount;
      }
      if (braceCount > 0) {
        cleaned += '}' * braceCount;
      }
      _logger.d('After appending closing brackets/braces: $cleaned');
    } else {
      cleaned = cleaned.substring(startIndex, endIndex + 1);
    }

    // Step 4: Remove trailing commas and excessive whitespace
    cleaned =
        cleaned
            .replaceAll(RegExp(r',\s*([}\]])'), r'\1')
            .replaceAll(RegExp(r'\n\s*\n'), '\n')
            .trim();

    _logger.d('After cleaning: $cleaned');

    // Step 5: Verify that the cleaned content is parseable JSON
    try {
      jsonDecode(cleaned);
    } catch (e) {
      _logger.e('Cleaned content is not valid JSON: $cleaned, Error: $e');
      throw DeepseekResponseValidationException(
        'Cleaned content is not valid JSON: $e',
      );
    }

    return cleaned;
  }

  Future<Map<String, dynamic>> _parseJsonSafely(String content) async {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('JSON parsing failed for content: $content');
      throw FormatException('Invalid JSON format: $e');
    }
  }

  bool _validateResponse(Map<String, dynamic> json, int targetWordCount) {
    try {
      if (!json.containsKey('contextOfText') ||
          json['contextOfText'] is! String ||
          json['contextOfText'].isEmpty ||
          !json.containsKey('contextOfTextTranslated') ||
          json['contextOfTextTranslated'] is! String ||
          json['contextOfTextTranslated'].isEmpty ||
          !json.containsKey('complexWordsWithExamples') ||
          json['complexWordsWithExamples'] is! List) {
        _logger.e('Missing or invalid required fields');
        return false;
      }

      final wordList = json['complexWordsWithExamples'] as List;
      if (wordList.isEmpty || wordList.length != targetWordCount) {
        _logger.e(
          'Word list length mismatch: ${wordList.length} vs $targetWordCount',
        );
        return false;
      }

      for (var wordEntry in wordList) {
        if (wordEntry is! Map<String, dynamic> ||
            !wordEntry.containsKey('word') ||
            wordEntry['word'] is! String ||
            wordEntry['word'].isEmpty ||
            !wordEntry.containsKey('wordType') ||
            wordEntry['wordType'] is! String ||
            wordEntry['wordType'].isEmpty ||
            !wordEntry.containsKey('wordTranslated') ||
            wordEntry['wordTranslated'] is! String ||
            wordEntry['wordTranslated'].isEmpty ||
            !wordEntry.containsKey('wordExplanation') ||
            wordEntry['wordExplanation'] is! String ||
            wordEntry['wordExplanation'].isEmpty ||
            !wordEntry.containsKey('examples') ||
            wordEntry['examples'] is! List ||
            (wordEntry['examples'] as List).length != 3) {
          _logger.e('Invalid word entry structure');
          return false;
        }

        for (var example in wordEntry['examples']) {
          if (example is! Map<String, dynamic> ||
              !example.containsKey('sentence') ||
              example['sentence'] is! String ||
              example['sentence'].isEmpty ||
              !example.containsKey('translation') ||
              example['translation'] is! String ||
              example['translation'].isEmpty) {
            _logger.e('Invalid example structure');
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      _logger.e('Validation error: $e');
      return false;
    }
  }
}

// Custom exceptions
class DeepseekException implements Exception {
  final String message;
  DeepseekException(this.message);
  @override
  String toString() => 'DeepseekException: $message';
}

class DeepseekApiException extends DeepseekException {
  final int? statusCode;
  DeepseekApiException(String message, [this.statusCode]) : super(message);
}

class DeepseekResponseValidationException extends DeepseekException {
  DeepseekResponseValidationException(String message) : super(message);
}
