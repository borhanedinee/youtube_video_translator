import 'package:Transcripto/presentation/controllers/saved_words_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/core/themes/app_themes.dart';
import 'package:Transcripto/domain/models/response_model.dart';

class WordDetailsScreen extends StatelessWidget {
  final ComplexWord word;

  const WordDetailsScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder:
            (context, constraints) => Container(
              height: constraints.maxHeight,
              decoration: AppThemes.backgroundGradient,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            GetBuilder<SavedWordsController>(
                              builder:
                                  (controller) => IconButton(
                                    onPressed: () async {
                                      final success = await controller
                                          .deleteComplexWord(word.word);
                                      if (success) {
                                        Navigator.of(context).pop();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Deleted Successfully.',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Something went wrong deleting the word.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              word.wordTranslated,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildWordTypeCard(context),
                      const SizedBox(height: 16),
                      _buildDefinitionCard(context),
                      const SizedBox(height: 16),
                      _buildExamplesCard(context),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildWordTypeCard(BuildContext context) {
    // Extract word type from wordExplanation (e.g., "Verb: ...")
    final wordType = word.wordType;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
              wordType,
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

  Widget _buildDefinitionCard(BuildContext context) {
    // Extract definition from wordExplanation (e.g., after "Verb: ")
    final definition =
        word.wordExplanation.contains(':')
            ? word.wordExplanation.split(':').sublist(1).join(':').trim()
            : word.wordExplanation;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
            definition,
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

  Widget _buildExamplesCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
            itemCount: word.examples.length,
            itemBuilder: (context, index) {
              final example = word.examples[index];
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
}
