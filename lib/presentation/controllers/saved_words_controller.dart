import 'package:Transcripto/data/local/local_db_helper.dart';
import 'package:Transcripto/domain/models/response_model.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SavedWordsController extends GetxController {
  DatabaseHelper databaseHelper;
  SavedWordsController(this.databaseHelper);

  List<ComplexWord> savedComplexWords = [];

  Future<bool> insertComplexWord(ComplexWord complexWord) async {
    try {
      bool success = await databaseHelper.insertComplexWord(complexWord);
      print(success);
      if (success) {
        savedComplexWords.add(complexWord);
        update();
      }
      return success;
    } catch (e) {
      print('error inserting word $e');
      return false;
    }
  }

  bool isFetchingSavedWords = false;
  Future<void> getComplexWords() async {
    try {
      savedComplexWords.clear();
      isFetchingSavedWords = true;
      update();

      // For testing delay only; remove in production
      await Future.delayed(Duration(seconds: 1));

      final data = await databaseHelper.getAllComplexWords();
      for (var word in data) {
        print(word);
        final complexWord = ComplexWord.fromJson(word);
        savedComplexWords.add(complexWord);
      }
    } catch (e) {
      print('Error loading complex words: $e');
    } finally {
      isFetchingSavedWords = false;
      update();
    }
  }

  Future<bool> deleteComplexWord(String word) async {
    try {
      final success = await databaseHelper.deleteComplexWord(word);
      if (success) {
        savedComplexWords.removeWhere((element) => element.word == word);
        update();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  bool isWordSaved(ComplexWord word) {
    if (savedComplexWords.isEmpty) return false;
    return savedComplexWords.any((element) => element.word == word.word);
  }
}
