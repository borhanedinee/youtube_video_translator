import 'package:Transcripto/presentation/screens/word_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/core/themes/app_themes.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/presentation/controllers/saved_words_controller.dart';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  @override
  void initState() {
    Get.find<SavedWordsController>().getComplexWords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder:
            (context, constraints) => GetBuilder<SavedWordsController>(
              builder:
                  (controller) => Stack(
                    children: [
                      Container(
                        height: constraints.maxHeight,
                        decoration: AppThemes.backgroundGradient,
                        child:
                            controller.isFetchingSavedWords
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : controller.savedComplexWords.isEmpty
                                ? Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade50,
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TweenAnimationBuilder(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: 1,
                                          ),
                                          duration: const Duration(seconds: 1),
                                          builder: (
                                            context,
                                            double value,
                                            child,
                                          ) {
                                            return Transform.rotate(
                                              angle: value * 0.1,
                                              child: Icon(
                                                Icons.bookmark_border,
                                                size: 70,
                                                color: AppThemes.primaryColor,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'No Saved Words',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppThemes.primaryColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'You haven’t saved any complex words yet. Analyze a new transcript to start building your vocabulary!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 28),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppThemes.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 14,
                                            ),
                                            elevation: 3,
                                          ),
                                          child: const Text(
                                            'Analyze New Transcript',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 24.0,
                                      ),
                                      itemCount:
                                          controller.savedComplexWords.length,
                                      itemBuilder: (context, index) {
                                        final word =
                                            controller.savedComplexWords[index];
                                        return Card(
                                          elevation: 3,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16.0),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 16,
                                            ),
                                            title: Text(
                                              word.word,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            subtitle: Text(
                                              word.wordTranslated,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            onTap: () {
                                              Get.to(
                                                () => WordDetailsScreen(
                                                  word: word,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                      ),
                      Positioned(
                        left: 16,
                        top: 46,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
            ),
      ),
    );
  }
}
