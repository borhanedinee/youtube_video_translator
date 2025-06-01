import 'package:youtube_player_flutter/youtube_player_flutter.dart';

String getIDByPackage(String url) {
  try {
    final videoId = YoutubePlayer.convertUrlToId(url);
    print('this is $videoId');
    return videoId ?? '';
  } on Exception catch (exception) {
    return '';
  } catch (error) {
    return '';
  }
}

String getYouTubeVideoId(String url) {
  String? videoId = YoutubePlayer.convertUrlToId(url);
  if (videoId != null && videoId.isNotEmpty) {
    print('method1 success : video id is $videoId');
    return videoId;
  }

  RegExp regExp = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    caseSensitive: false,
  );

  Match? match = regExp.firstMatch(url);
  videoId = match?.group(1);
  print('method1 fail method2 success : video id is $videoId');
  if (videoId != null && videoId.isNotEmpty) {
    print('method1 success : video id is $videoId');
    return videoId;
  }
  print('no video id found');
  return '';
}

bool isYouTubeVideoLink(String link) {
  // final youtubePatterns = [
  //   r'^https?://(?:www\.)?youtube(?:-nocookie)?\.com/(?:watch\?v=|embed/|v/|shorts/)?[a-zA-Z0-9_-]{11}(?:\?[^"\s]*)?$',
  //   r'^https?://youtu\.be/[a-zA-Z0-9_-]{11}(?:\?[^"\s]*)?$',
  // ];
  // return youtubePatterns.any((pattern) => RegExp(pattern).hasMatch(link));
  String? videoId = YoutubePlayer.convertUrlToId(link);
  if (videoId != null && videoId.isNotEmpty) {
    print('method1 success : video id is $videoId');
    return true;
  }

  RegExp regExp = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    caseSensitive: false,
  );

  Match? match = regExp.firstMatch(link);
  videoId = match?.group(1);
  print('method1 fail method2 success : video id is $videoId');

  return videoId != null && videoId.isNotEmpty;
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
