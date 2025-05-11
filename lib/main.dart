import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/models/user_model.dart';
import 'package:youtube_downloader/screens/home_screen.dart';
import 'package:youtube_downloader/screens/user_info_screen.dart';
import 'package:youtube_downloader/services/complex_words_detector.dart';
import 'package:youtube_downloader/services/download_youtube_video_service.dart';
import 'package:youtube_downloader/services/user_info_service.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

late Size size;
UserModel? currentUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    Get.put(DownloadYoutubeVideoService());
    Get.put(ComplexWordsDetector());
    Get.put(UserInfoService());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserInfoScreen(),
    );
  }
}
