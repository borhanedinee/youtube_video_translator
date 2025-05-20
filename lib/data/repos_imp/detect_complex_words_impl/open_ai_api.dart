import 'dart:convert';
import 'package:Transcripto/core/constants/api_keys.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/domain/repos/detect_complex_words_repo.dart';
import 'package:http/http.dart' as http;

class OpenAIDetection implements DetectComplexWordsRepo {
  final String _model =
      'gpt-4.1'; // You can switch to 'gpt-3.5-turbo' if needed.

  @override
  Future<ResponseModel?> getComplexWordsByText(
    String transcript,
    String level,
    String fromLanguage,
    String toLanguage,
  ) async {
    print('Prompting OpenAI...');

    final url = 'https://api.openai.com/v1/chat/completions';

    final prompt = '''
You are an intelligent assistant that helps language learners expand their vocabulary through real-life video content.

Here is the transcript of a video in $toLanguage:

"$transcript"

User Details:
- Native Language: $fromLanguage
- Target Language (learning): $toLanguage
- Proficiency Level: "$level" (based on CEFR scale: A1, A2, B1, B2, C1, C2)

Your task:

1. Analyze the transcript to determine its length:
   - short (< 50 words)
   - medium (50–150 words)
   - long (> 150 words)

2. Extract complex words from the transcript that would be challenging for a user at the "$level" level. Use the following criteria:
   - A1 → extract 50% of all unique words (focusing on words above basic 1000 vocabulary)
   - A2 → extract 40%
   - B1 → extract 30%
   - B2 → extract 25%
   - C1 → extract 15%
   - C2 → extract 10%

   Ensure:
   - You calculate the total number of unique words in the transcript.
   - Then extract the appropriate percentage based on the user’s level.
   - Prioritize less frequent, topic-specific, or idiomatic words.

3. Return the response in this strict JSON format (no markdown, no explanations, no code fences):

{
  "contextOfText": "<Short summary of what the transcript is about, written in $toLanguage>",
  "contextOfTextTranslated": "<Translation of the summary in $fromLanguage>",
  "complexWordsWithExamples": [
    {
      "word": "<Complex word in $toLanguage>",
      "wordType": "<Type of word, in $fromLanguage (e.g., noun, verb)>",
      "wordTranslated": "<Translation of the word in $fromLanguage>",
      "wordExplanation": "<Word type and simple explanation in $toLanguage>",
      "examples": [
        {
          "sentence": "<Example sentence using the word in $toLanguage>",
          "translation": "<Translation of the sentence in $fromLanguage>"
        },
        {
          "sentence": "<Another example sentence>",
          "translation": "<Translation>"
        },
        {
          "sentence": "<Another example sentence>",
          "translation": "<Translation>"
        }
      ]
    }
    // Repeat for all selected complex words
  ]
}

4. If no complex words are found based on the user's level, return random 4 words based on the user’s level.

Important Rules:
- DO NOT return markdown or wrap the JSON in any code block.
- Ensure the number of complex words matches the level-based percentage.
- Translations must be accurate and natural for learners.
''';

    final requestBody = {
      "model": _model,
      "temperature": 0.3,
      "max_tokens": 2048,
      "messages": [
        {
          "role": "system",
          "content":
              "You are a helpful assistant that returns clean JSON outputs.",
        },
        {"role": "user", "content": prompt},
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAI_API_KEY",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices']?[0]?['message']?['content'];

        if (content == null || content.isEmpty) {
          throw Exception("Empty content from OpenAI response");
        }

        final cleanedContent = cleanJsonResponse(content);
        final decodedJson = jsonDecode(cleanedContent);

        return ResponseModel.fromJson(decodedJson);
      } else {
        print("OpenAI API error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("OpenAI HTTP Error: $e");
      return null;
    }
  }

  String cleanJsonResponse(String raw) {
    print('Cleaning JSON...');
    return raw.replaceAll('```json', '').replaceAll('```', '').trim();
  }
}
