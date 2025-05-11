import 'dart:convert';
import 'dart:io';

import 'package:assemblyai_flutter_sdk/assemblyai_flutter_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_downloader/constants/api_keys.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class DownloadYoutubeVideoService extends GetxController {
  String? transcriptionResult = '';
  final yt = YoutubeExplode();
  final audioPlayer = AudioPlayer();

  // statuse
  bool isProcessingVideo = false;
  bool isProcessingVideoInitial = true;
  bool isConvertingToAudio = false;
  bool isConvertingToAudioInitial = true;
  bool isConvertingToText = false;
  bool isConvertingToTextInitial = true;
  bool isDetectingHardWords = false;
  bool isDetectingHardWordsInitial = true;

  Future<bool> requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      print("Storage permission is granted");
      return true;
    } else {
      print("Storage permission is not granted");
      return false;
    }
  }

  Future<void> processVideo(String videoId, String langCode) async {
    try {
      isProcessingVideoInitial = false;
      isProcessingVideo = true;
      update();
      transcriptionResult = '';
      if (!await requestStoragePermission()) {
        print("❌ Storage permission not granted");
        return;
      }

      final file = await downloadAudioFromYoutube(videoId);
      if (file == null) return;

      // Optional playback
      // await playAudio(file);
      isProcessingVideo = false;
      isConvertingToAudioInitial = false;
      isConvertingToAudio = true;
      update();

      final uploadUrl = await uploadFileToAssemblyAI(file);
      if (uploadUrl == null) throw Exception("❌ Upload failed");
      update();

      final transcribtionId = await requestTranscriptionId(uploadUrl, langCode);
      if (transcribtionId == null) {
        throw Exception("❌ Fetching ID failed");
      }

      isConvertingToAudio = false;
      isConvertingToTextInitial = false;
      isConvertingToText = true;
      update();
      await Future.delayed(Duration(seconds: 30));
      print('Future done ...');

      final transcription = await fetchTranscriptionByID(transcribtionId);

      transcriptionResult = transcription;

      update();
    } catch (e, stack) {
      setInitialStateOfLoaders();
      print('❌ Error: $e');
      print(stack);
    }
  }

  setInitialStateOfLoaders() {
    isProcessingVideoInitial = true;
    isConvertingToAudioInitial = true;
    isConvertingToTextInitial = true;

    isProcessingVideo = false;
    isConvertingToAudio = false;
    isConvertingToText = false;
    update();
  }

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
      return data['upload_url'];
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
      print('Transcribe Audio Success... ');
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
      final url = Uri.parse(
        '$ASSEMBLY_API_BASE_URL/transcript/$transcribtionId',
      );

      final headers = {'Authorization': ASSEMBLAI_API_KEY};

      final request = await http.get(url, headers: headers);

      final jsonRs = json.decode(request.body);

      print('Transcription Fetched ${jsonRs}');
      return jsonRs['text'];
    } catch (e) {
      print('Transcription fetch failed $e');
      return null;
    }
  }

  Future<void> playAudio(File file) async {
    await audioPlayer.setFilePath(file.path);
    await audioPlayer.play();
    await Future.delayed(Duration(seconds: 10));
    await audioPlayer.stop();
  }
}
