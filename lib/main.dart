import 'package:Transcripto/core/constants/api_keys.dart';
import 'package:Transcripto/data/local/local_db_helper.dart';
import 'package:Transcripto/data/repos_imp/detect_complex_words_impl/deepSeekDetection.dart';
import 'package:Transcripto/data/repos_imp/detect_complex_words_impl/gemini_detection.dart';
import 'package:Transcripto/data/repos_imp/detect_complex_words_impl/open_ai_api.dart';
import 'package:Transcripto/data/repos_imp/extract_text_repo_impl.dart';
import 'package:Transcripto/domain/repos/detect_complex_words_repo.dart';
import 'package:Transcripto/domain/repos/extract_text_repo.dart';
import 'package:Transcripto/presentation/controllers/saved_words_controller.dart';
import 'package:Transcripto/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Transcripto/domain/models/user_model.dart';
import 'package:Transcripto/presentation/screens/user_info_screen.dart';
import 'package:Transcripto/presentation/controllers/process_video_controller.dart';
import 'package:Transcripto/presentation/controllers/user_info_service.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Add this line
  Gemini.init(apiKey: GEMINI_API_KEY);
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

late Size size;
UserModel? currentUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    ExtractTextRepo extractTextRepo = ExtractTextRepoImpl();
    DetectComplexWordsRepo deepSeekApi = DeepseekDetection();
    DetectComplexWordsRepo geminiApi = GeminiDetection();

    Get.put(ProcessVideoController(extractTextRepo, deepSeekApi));
    Get.put(UserInfoService());
    Get.put(SavedWordsController(DatabaseHelper.instance));

    if (prefs.containsKey('username')) {
      final username = prefs.getString('username');
      final languageToLearn = prefs.getString('tolang');
      final level = prefs.getString('level');
      final nativeLanguage = prefs.getString('fromlang');
      currentUser = UserModel(
        username: username!,
        toLang: languageToLearn!,
        fromLang: nativeLanguage!,
        level: level!,
      );
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: prefs.containsKey('username') ? HomeScreen() : UserInfoScreen(),
    );
  }
}
