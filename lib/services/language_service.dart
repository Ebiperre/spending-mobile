import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, pidgin }

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isPidgin => _currentLanguage == AppLanguage.pidgin;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langStr = prefs.getString(_languageKey) ?? 'english';
    _currentLanguage = langStr == 'pidgin' ? AppLanguage.pidgin : AppLanguage.english;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language == AppLanguage.pidgin ? 'pidgin' : 'english');
    notifyListeners();
  }

  String get languageName => _currentLanguage == AppLanguage.pidgin ? 'Pidgin' : 'English';
}
