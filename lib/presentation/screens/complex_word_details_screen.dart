import 'package:Transcripto/presentation/controllers/process_video_controller.dart';
import 'package:Transcripto/presentation/controllers/saved_words_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:Transcripto/presentation/screens/video_summary_screen.dart';
import 'package:Transcripto/core/themes/app_themes.dart';

class ComplexWordDetailsScreen extends StatelessWidget {
  const ComplexWordDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder:
            (context, constraints) => GetBuilder<ProcessVideoController>(
              builder: (controller) {
                final ComplexWord word = controller.getCurrentWord()!;
                return Container(
                  height: constraints.maxHeight,
                  decoration: AppThemes.backgroundGradient,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.word,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  word.wordTranslated, // Assuming this is the translation in the target language
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildWordTypeCard(word, context),
                                const SizedBox(height: 16),
                                _buildDefinitionCard(word, context),
                                const SizedBox(height: 16),
                                _buildExamplesCard(word.examples, context),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                        GetBuilder<SavedWordsController>(
                          builder:
                              (savedWordsController) => Positioned(
                                right: 24,
                                top: 24,
                                child: IconButton(
                                  onPressed: () async {
                                    print('inserting..');
                                    final success = await savedWordsController
                                        .insertComplexWord(word);
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Saved Successfully.'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Something went wrong saving the word.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    savedWordsController.isWordSaved(word)
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: _buildNavigationButton(controller, context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildWordTypeCard(ComplexWord word, BuildContext context) {
    return AnimatedContainer(
      duration: Durations.medium4,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.label_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(
            'WORD TYPE',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              word.wordType,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionCard(ComplexWord word, BuildContext context) {
    return AnimatedContainer(
      duration: Durations.medium4,

      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_border, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'DEFINITION',
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
            word.wordExplanation, // Extract definition part
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesCard(List<Example> examples, BuildContext context) {
    return AnimatedContainer(
      duration: Durations.medium4,

      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'EXAMPLE SENTENCES',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: examples.length,
            itemBuilder: (context, index) {
              final example = examples[index];
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.sentence,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Translation: ${example.translation}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    ProcessVideoController controller,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.width,
            child: Row(
              children: [
                controller.isFirstWord()
                    ? SizedBox()
                    : Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!controller.isFirstWord()) {
                            controller.previousWord();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 4,
                        ),
                        label: Text(
                          'Previous Word',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        iconAlignment: IconAlignment.start,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                SizedBox(width: controller.isFirstWord() ? 0 : 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (controller.isLastWord()) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => VideoSummarScreen(),
                          ),
                        );
                        controller.currentIndex = 0;
                      } else {
                        controller.nextWord();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4,
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: Text(
                      controller.isLastWord() ? 'Show Context' : 'Next Word',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.currentIndex + 1} of ${controller.detectedWordsResponseModel!.complexWordsWithExamples.length} words',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
