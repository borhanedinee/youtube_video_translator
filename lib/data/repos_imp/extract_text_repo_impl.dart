import 'dart:convert';
import 'dart:io';

import 'package:Transcripto/core/constants/api_keys.dart';
import 'package:Transcripto/domain/repos/extract_text_repo.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class ExtractTextRepoImpl implements ExtractTextRepo {
  final yt = YoutubeExplode();
  final audioPlayer = AudioPlayer();

  Future<File?> downloadAudioFromYoutube(String videoId) async {
    print('📥 Fetching stream manifest...');
    final manifest = await yt.videos.streamsClient.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.ios, YoutubeApiClient.androidVr],
    );

    final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
    if (audioStreamInfo == null) {
      print("❌ No audio stream available");
      return null;
    }

    final audioStream = yt.videos.streamsClient.get(audioStreamInfo);
    final dir = await getDownloadsDirectory();
    if (dir == null) throw Exception('❌ Could not get download directory');

    final file = File('${dir.path}/$videoId.mp3');
    final output = file.openWrite();
    await audioStream.pipe(output);
    await output.flush();
    await output.close();

    print('✅ Audio downloaded to ${file.path}');
    return file;
  }

  Future<String?> uploadFileToAssemblyAI(File file) async {
    print('Uploading file...');
    final url = Uri.parse('$ASSEMBLY_API_BASE_URL/upload');
    final request =
        http.Request('POST', url)
          ..headers['Authorization'] = ASSEMBLAI_API_KEY
          ..bodyBytes = await file.readAsBytes();

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Upload Audio Success...');
      final data = jsonDecode(body);
      final upload_url = data['upload_url'];
      return upload_url;
    } else {
      print('Upload Audio failed: $body');
      return null;
    }
  }

  Future<String?> requestTranscriptionId(
    String uploadUrl,
    String langCode,
  ) async {
    print('Requesting Transcribing...');

    final speechModel = langCode == 'ar' ? 'nano' : 'universal';

    final uri = Uri.parse('$ASSEMBLY_API_BASE_URL/transcript');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': ASSEMBLAI_API_KEY,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'audio_url': uploadUrl,
        'language_code': langCode,
        'language_detection': false,
        'speech_model': speechModel,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final id = json['id'];
      return id;
    } else {
      print(
        'Transcription failed: ${response.statusCode} body: ${response.body}',
      );
      return null;
    }
  }

  Future<String?> fetchTranscriptionByID(String transcribtionId) async {
    try {
      String status = '';
      int count = 0;

      while (status.toLowerCase() != 'completed') {
        print('count ${count++}');
        final url = Uri.parse(
          '$ASSEMBLY_API_BASE_URL/transcript/$transcribtionId',
        );

        final headers = {'Authorization': ASSEMBLAI_API_KEY};

        final request = await http.get(url, headers: headers);

        final jsonRs = json.decode(request.body);
        status = jsonRs['status'];
        print('ya borhaaaaaaan : $status');
        if (status.toLowerCase() == 'completed') {
          return jsonRs['text'];
        }
        await Future.delayed(Duration(seconds: 3));
      }
    } catch (e) {
      print('Transcription fetch failed $e');
      return null;
    }
    return null;
  }

  Future<void> playAudio(File file) async {
    await audioPlayer.setFilePath(file.path);
    await audioPlayer.play();
    await Future.delayed(Duration(seconds: 10));
    await audioPlayer.stop();
  }

  @override
  Future<String?> getTextFromVideo(
    String videoID,
    String langCodeOfVideo,
  ) async {
    final file = await downloadAudioFromYoutube(videoID);
    if (file == null) return null;
    final uploadUrl = await uploadFileToAssemblyAI(file);
    if (uploadUrl == null) return null;
    final transId = await requestTranscriptionId(uploadUrl, langCodeOfVideo);
    if (transId == null) return null;
    final transcriptionText = await fetchTranscriptionByID(transId);
    return transcriptionText;
  }
}
