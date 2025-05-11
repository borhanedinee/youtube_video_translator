import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_downloader/main.dart';
import 'package:youtube_downloader/screens/complex_word_details_screen.dart';
import 'package:youtube_downloader/services/complex_words_detector.dart';
import 'package:youtube_downloader/services/download_youtube_video_service.dart';
import 'package:youtube_downloader/services/youtube_video_services.dart';
import 'package:youtube_downloader/themes/app_themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _youtubeController = TextEditingController();
  final processVideoController = Get.find<DownloadYoutubeVideoService>();
  final complexWordsDetector = Get.find<ComplexWordsDetector>();

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  void _onAnalyzePressed() async {
    if (_youtubeController.text.isNotEmpty &&
        isYouTubeVideoLink(_youtubeController.text)) {
      final videoID = getYouTubeVideoId(_youtubeController.text);
      final langCode = 'en';
      await processVideoController.processVideo(videoID, langCode);
      if (processVideoController.transcriptionResult == null ||
          processVideoController.transcriptionResult == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Something went wrong processing the video, please try again.',
            ),
          ),
        );
        return;
      }
      final transcript = processVideoController.transcriptionResult;
      await complexWordsDetector.detectComplexWordsInText(
        transcript!,
        fromLanguage: 'english',
        toLanguage: 'arabic',
      );
      processVideoController.setInitialStateOfLoaders();
      if (complexWordsDetector.detectedWordsResponseModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detected words model is null.')),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ComplexWordDetailsScreen(),
        ),
      );
      _youtubeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid youtube video link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height:
                constraints
                    .maxHeight, // Use the full height provided by Scaffold
            decoration: AppThemes.backgroundGradient,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 30.0,
                  ),
                  child: GetBuilder<DownloadYoutubeVideoService>(
                    builder:
                        (videoController) => GetBuilder<ComplexWordsDetector>(
                          builder:
                              (controller) => Column(
                                mainAxisSize:
                                    MainAxisSize
                                        .max, // Ensure Column takes full height
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Video Translator',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Paste a YouTube link to analyze and translate its content.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.95),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 12,
                                          spreadRadius: 3,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _youtubeController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter YouTube video link',
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 14.0,
                                            ),
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: _onAnalyzePressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppThemes.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 6,
                                        shadowColor: AppThemes.primaryColor
                                            .withOpacity(0.3),
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Analyze',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildStatusRow(
                                          'Processing Video',
                                          Icons.videocam_rounded,
                                          videoController.isProcessingVideo,
                                          videoController
                                              .isProcessingVideoInitial,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStatusRow(
                                          'Converting Video to Audio',
                                          Icons.audiotrack,
                                          videoController.isConvertingToAudio,
                                          videoController
                                              .isConvertingToAudioInitial,
                                        ),
                                        const SizedBox(height: 12),

                                        _buildStatusRow(
                                          'Extracting Text from Audio',
                                          Icons.transcribe,
                                          videoController.isConvertingToText,
                                          videoController
                                              .isConvertingToTextInitial,
                                        ),
                                        const SizedBox(height: 12),

                                        _buildStatusRow(
                                          'Detecting Complex Words Based on your Level',
                                          Icons.spellcheck,
                                          controller.isPrompting,
                                          controller.isInitialState,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(
    String status,
    IconData iconData,
    bool isLoading,
    bool isInitialState,
  ) {
    return SizedBox(
      width: size.width,
      child: Row(
        children: [
          Icon(iconData, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: size.width * .5,
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Spacer(),

          isInitialState
              ? Icon(Icons.remove_circle_outline, color: Colors.grey)
              : isLoading
              ? SpinKitFadingCircle(color: AppThemes.primaryColor, size: 25.0)
              : Icon(Icons.check_circle_rounded, color: AppThemes.primaryColor),
        ],
      ),
    );
  }
}
