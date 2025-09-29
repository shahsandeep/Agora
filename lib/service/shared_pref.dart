import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
   final String userTokenKey = "USER_TOKEN";

   Future<void> saveUserToken(String userToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userTokenKey, userToken);
  }

   Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userTokenKey);
  }

   Future<void> deleteUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userTokenKey);
  }
}
