import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AppProvider with ChangeNotifier {
  UserModel? _currentUser;
  String _currentLanguage = 'en';
  bool _isDarkMode = false;

  UserModel? get currentUser => _currentUser;
  String get currentLanguage => _currentLanguage;
  bool get isDarkMode => _isDarkMode;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _currentLanguage = user.languagePreference;
      _isDarkMode = user.darkMode;
    }
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  String translate(String key) {
    return key;
  }
}
