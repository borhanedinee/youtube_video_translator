import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_downloader/pages/home_screen.dart';
import 'package:youtube_downloader/services/complex_words_detector.dart';
import 'package:youtube_downloader/services/download_youtube_video_service.dart';

void main() {
  runApp(MyApp());
}

late Size size;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    Get.put(DownloadYoutubeVideoService());
    Get.put(ComplexWordsDetector());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
