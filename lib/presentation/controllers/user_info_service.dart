import 'package:get/get.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/helpers/shared_preferences_helper.dart';
import 'package:Transcripto/domain/models/user_model.dart';

class UserInfoService extends GetxController {
  String get languageToLearn => currentUser?.toLang ?? '';
  String get languageFrom => currentUser?.fromLang ?? '';
  set languageFrom(String lang) {
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(fromLang: lang);
    } else {
      // If no current user exists yet (initial setup), create a minimal user
      currentUser = UserModel(username: '', toLang: '', fromLang: lang, level: '');
    }
  }

  set languageToLearn(String lang) {
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(toLang: lang);
    } else {
      currentUser = UserModel(username: '', toLang: lang, fromLang: '', level: '');
    }
  }

  bool isSavingUser = false;
  Future<bool> saveUserInfo(
    String userName,
    String currentLevel,
  ) async {
    try {
      String toLanguage = languageToLearn;
      String fromLanguage = languageFrom;
      isSavingUser = true;
      update();
      await Future.delayed(Duration(seconds: 3));
      // Use the helper so keys and normalization are centralized
      await SharedPreferencesHelper.saveUserInfo(
        username: userName,
        level: currentLevel,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
      );

      currentUser = UserModel(
        username: userName,
        toLang: toLanguage,
        fromLang: fromLanguage,
        level: currentLevel,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isSavingUser = false;

      update();
    }
  }
}
