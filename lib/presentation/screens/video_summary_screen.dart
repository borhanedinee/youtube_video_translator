import 'package:Transcripto/presentation/controllers/process_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/core/themes/app_themes.dart';

class VideoSummarScreen extends StatelessWidget {
  const VideoSummarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: AppThemes.backgroundGradient,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Summary',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Overview of the translated video content.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      color: Colors.black54,
                                      size: 16,
                                    ),
                                    Text(
                                      'Original Language (${currentUser!.toLang.toUpperCase()})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Get.find<ProcessVideoController>()
                                      .detectedWordsResponseModel!
                                      .contextOfText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Icons.public,
                                      color: Colors.black54,
                                      size: 16,
                                    ),
                                    Text(
                                      'In Your Language (${currentUser!.fromLang.toUpperCase()})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Get.find<ProcessVideoController>()
                                      .detectedWordsResponseModel!
                                      .contextOfTextTranslated,

                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildDoneButton(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Done',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            const Icon(Icons.done, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
