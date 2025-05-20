import 'dart:math';

import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/domain/repos/detect_complex_words_repo.dart';
import 'package:Transcripto/domain/repos/extract_text_repo.dart';
import 'package:get/get.dart';

class ProcessVideoController extends GetxController {
  ExtractTextRepo extractTextRepo;
  DetectComplexWordsRepo detectComplexWordsApi;
  ProcessVideoController(this.extractTextRepo, this.detectComplexWordsApi);

  // data to show in UI
  ResponseModel? detectedWordsResponseModel;

  // statuse
  bool shouldAnalyzeVideo = true;
  bool isProcessingVideo = false;
  bool isProcessingVideoInitial = true;
  bool isConvertingToAudio = false;
  bool isConvertingToAudioInitial = true;
  bool isConvertingToText = false;
  bool isConvertingToTextInitial = true;
  bool isDetectingHardWords = false;
  bool isDetectingHardWordsInitial = true;

  Future<void> changingLoadersState() async {
    final random = Random();
    isProcessingVideo = true;
    isProcessingVideoInitial = false;
    update();
    await Future.delayed(Duration(seconds: 5));
    isProcessingVideo = false;
    isConvertingToAudio = true;
    isConvertingToAudioInitial = false;
    update();

    final secondsToWait = 7 + random.nextInt(10 - 7 + 1);
    await Future.delayed(Duration(seconds: secondsToWait));
    isConvertingToAudio = false;
    update();
  }

  void setLoadersInititialState() {
    isProcessingVideo = false;
    isProcessingVideoInitial = true;
    isConvertingToAudio = false;
    isConvertingToAudioInitial = true;
    isConvertingToText = false;
    isConvertingToTextInitial = true;
    isDetectingHardWords = false;
    isDetectingHardWordsInitial = true;
  }

  Future<bool> processVideo(
    String videoId,
    String langCode,
    String lanToLearn,
    String nativeLang,
    String level,
  ) async {
    try {
      shouldAnalyzeVideo = false;

      await changingLoadersState();

      isConvertingToText = true;
      isConvertingToTextInitial = false;
      update();
      final transcriptionResult = await extractTextRepo.getTextFromVideo(
        videoId,
        langCode,
      );

      isConvertingToText = false;

      isDetectingHardWords = true;
      isDetectingHardWordsInitial = false;
      update();
      if (transcriptionResult == null) return false;
      detectedWordsResponseModel = await detectComplexWordsApi
          .getComplexWordsByText(
            transcriptionResult,
            level,
            lanToLearn,
            nativeLang,
          );
      shouldAnalyzeVideo = true;
      setLoadersInititialState();
      update();
      return true;
    } catch (e) {
      print('error $e');
      shouldAnalyzeVideo = true;
      setLoadersInititialState();
      update();

      return false;
    }
  }

  // response helpers
  int currentIndex = 0;
  bool isLastWord() {
    return detectedWordsResponseModel != null &&
        currentIndex ==
            detectedWordsResponseModel!.complexWordsWithExamples.length - 1;
  }

  bool isFirstWord() {
    return currentIndex == 0;
  }

  void nextWord() {
    if (!isLastWord()) {
      currentIndex++;
      update();
    }
  }

  void previousWord() {
    if (!isFirstWord()) {
      currentIndex--;
      update();
    }
  }

  ComplexWord? getCurrentWord() {
    if (detectedWordsResponseModel != null &&
        detectedWordsResponseModel!.complexWordsWithExamples.isNotEmpty) {
      return detectedWordsResponseModel!.complexWordsWithExamples[currentIndex];
    }
    return null;
  }
}
