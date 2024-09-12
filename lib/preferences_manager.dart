import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const _isSignedKey = 'isSigned';

  // Save the sign-in status
  static Future<void> setSignedIn(bool isSigned) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSignedKey, isSigned);
    } catch (e) {
      // Handle any potential exceptions, such as I/O errors
      print("Error saving sign-in status: $e");
    }
  }

  // Get the sign-in status
  static Future<bool> getSignedInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isSignedKey) ?? false;
    } catch (e) {
      // Handle any potential exceptions, such as I/O errors
      print("Error fetching sign-in status: $e");
      return false; // Default to false in case of an error
    }
  }

  // Remove the sign-in status (for logout or clearing data)
  static Future<void> removeSignedInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isSignedKey);
    } catch (e) {
      // Handle any potential exceptions
      print("Error removing sign-in status: $e");
    }
  }
}
