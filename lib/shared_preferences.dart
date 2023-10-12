import 'package:shared_preferences/shared_preferences.dart';

class MyPref {
  static Future<String> getRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('role');
    return token.toString();
  }

  static Future<String> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('email');
    return token.toString();
  }

  static void saveUserRole(String role) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('role', role);
  }

  static void saveUserEmail(String email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('email', email);
  }
}
