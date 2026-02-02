import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
  
  void toggleLocale() {
    _locale = _locale.languageCode == 'en' 
        ? const Locale('ja') 
        : const Locale('en');
    notifyListeners();
  }
  
  String get currentLanguage {
    return _locale.languageCode == 'en' ? 'English' : '日本語';
  }
  
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isJapanese => _locale.languageCode == 'ja';
}