String getYouTubeVideoId(String url) {
  // Enhanced regular expression to match YouTube video ID across various formats
  final RegExp regExp = RegExp(
    r'(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?|watch)/?[^/\n\s]*[?&]?(?:v=)?)|youtu\.be/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );

  // Find the match in the URL
  final match = regExp.firstMatch(url);

  // Return the video ID if found, otherwise return empty string
  return match?.group(1) ?? '';
}

bool isYouTubeVideoLink(String link) {
  final youtubePatterns = [
    r'^https?://(?:www\.)?youtube(?:-nocookie)?\.com/(?:watch\?v=|embed/|v/|shorts/)?[a-zA-Z0-9_-]{11}(?:\?[^"\s]*)?$',
    r'^https?://youtu\.be/[a-zA-Z0-9_-]{11}(?:\?[^"\s]*)?$',
  ];
  return youtubePatterns.any((pattern) => RegExp(pattern).hasMatch(link));
}

String getLanguageCode(String language) {
  print('lan code for $language');
  switch (language.toLowerCase()) {
    case 'french':
      return 'fr';
    case 'spanish':
      return 'es';
    case 'arabic':
      return 'ar';
    default:
      throw ArgumentError('Unsupported language: $language');
  }
}
