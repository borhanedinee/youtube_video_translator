import 'package:get/get.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/domain/models/user_model.dart';

class UserInfoService extends GetxController {
  bool isSavingUser = false;
  Future<bool> saveUserInfo(
    String userName,
    String toLanguage,
    String currentLevel,
    String fromLanguage,
  ) async {
    try {
      isSavingUser = true;
      update();
      await Future.delayed(Duration(seconds: 3));
      await prefs.setString('username', userName.toLowerCase());
      await prefs.setString('tolang', toLanguage.toLowerCase());
      await prefs.setString('level', currentLevel.toLowerCase());
      await prefs.setString('fromlang', fromLanguage.toLowerCase());

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
