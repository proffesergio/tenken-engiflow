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
}