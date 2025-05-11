class ResponseModel {
  final String contextOfText;
  final String contextOfTextTranslated;
  final List<ComplexWord> complexWordsWithExamples;

  ResponseModel({
    required this.contextOfText,
    required this.contextOfTextTranslated,
    required this.complexWordsWithExamples,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      contextOfText: json['contextOfText'] as String,
      contextOfTextTranslated: json['contextOfTextTranslated'] as String,
      complexWordsWithExamples:
          (json['complexWordsWithExamples'] as List)
              .map((item) => ComplexWord.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contextOfText': contextOfText,
      'contextOfTextTranslated': contextOfTextTranslated,
      'complexWordsWithExamples':
          complexWordsWithExamples.map((word) => word.toJson()).toList(),
    };
  }
}

class ComplexWord {
  final String word;
  final String wordTranslated;
  final String wordExplanation;
  final List<Example> examples;

  ComplexWord({
    required this.word,
    required this.wordTranslated,
    required this.wordExplanation,
    required this.examples,
  });

  factory ComplexWord.fromJson(Map<String, dynamic> json) {
    return ComplexWord(
      word: json['word'] as String,
      wordTranslated: json['wordTranslated'] as String,
      wordExplanation: json['wordExplanation'] as String,
      examples:
          (json['examples'] as List)
              .map((item) => Example.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'wordTranslated': wordTranslated,
      'wordExplanation': wordExplanation,
      'examples': examples.map((example) => example.toJson()).toList(),
    };
  }
}

class Example {
  final String sentence;
  final String translation;

  Example({required this.sentence, required this.translation});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      sentence: json['sentence'] as String,
      translation: json['translation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sentence': sentence, 'translation': translation};
  }
}
