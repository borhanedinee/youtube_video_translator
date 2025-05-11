import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_downloader/constants/api_keys.dart';
import 'package:youtube_downloader/models/response_model.dart';

class ComplexWordsDetector extends GetxController {
  // DownloadYoutubeVideoService transcriptor;
  // ComplexWordsDetector(this.transcriptor);
  ResponseModel? detectedWordsResponseModel;
  int currentIndex = 0;

  // status
  bool isInitialState = true;
  bool isPrompting = true;

  bool isLastWord() {
    return currentIndex ==
        detectedWordsResponseModel!.complexWordsWithExamples.length - 1;
  }

  nextWord() {
    currentIndex++;
    update();
  }

  ComplexWord getCurrentWord() {
    return detectedWordsResponseModel!.complexWordsWithExamples[currentIndex];
  }

  Future<void> detectComplexWordsInText(
    String transcript, {
    String level = 'B1',
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      isInitialState = false;
      isPrompting = true;
      update();

      final prompt = '''
    Here is a transcript:

    "$transcript"

    The user's English level is "$level".

    From Language : $fromLanguage
    To Language : $toLanguage

    Your task:
    1. Identify the words in the transcript that would be challenging for someone at this level.
    2. Return the result in the following format:

    {
      "contextOfText": "<A short summary of what the transcript is about>",
      "contextOfTextTranslated": "<translation of contextOfText in the to language>",
      "complexWordsWithExamples": [
        {
          "word": "exampleComplexWord",
          "wordTranslated": "<translate the word in the to Language>",
          "wordExplanation": "<give trhe word type , eg noun verb ect , and imple explanation>",
          "examples": [
            {
              "sentence": "An example sentence using the word.",
              "translation": "La traduction de la phrase d'exemple."
            }
          ]
        },
        ...
      ]
    }

    for ech word give 3 exemples with their translation

    Only return a string in the given format not a json file or idk. Do not include any extra explanation or formatting outside the format given. This will be used directly and parsed inside json.decode(yourResponse) in an flutter application.
    ''';

      final response = await http.post(
        Uri.parse(DEEPSEEK_BASE_URL),
        headers: {
          'Authorization': 'Bearer $DEEPSEEK_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an English language assistant helping users improve their vocabulary.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.3,
        }),
      );

      print('Recieved Response from GPT...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        try {
          final detetctedWords = cleanJsonResponse(content);
          final detectedWordsJson = json.decode(detetctedWords);
          detectedWordsResponseModel = ResponseModel.fromJson(
            detectedWordsJson,
          );
        } catch (e) {
          print('Error decoding JSON array from GPT response: $e');
          throw Exception(e.toString());
        }
      } else {
        throw Exception('Deep Seek Response Code is ${response.statusCode}');
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(message: 'Something went wrong requesting deep seek $e'),
      );
    } finally {
      isInitialState = true;
      isPrompting = false;
      update();
    }
  }

  String cleanJsonResponse(String raw) {
    // Remove triple quotes or ```json/'''json
    return raw
        .replaceAll(RegExp(r"^```json|^'''json", multiLine: true), '')
        .replaceAll(RegExp(r"```$|'''$", multiLine: true), '')
        .trim();
  }
}
