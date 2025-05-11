String getYouTubeVideoId(String url) {
  // Regular expression to match YouTube video ID
  final RegExp regExp = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    caseSensitive: false,
  );

  // Find the match in the URL
  final match = regExp.firstMatch(url);

  // Return the video ID if found, otherwise return empty string
  return match?.group(1) ?? '';
}

bool isYouTubeVideoLink(String link) {
  final youtubePatterns = [
    r'^https?://(?:www\.)?youtube\.com/watch\?v=[\w-]+',
    r'^https?://youtu\.be/[\w-]+',
  ];
  return youtubePatterns.any((pattern) => RegExp(pattern).hasMatch(link));
}
