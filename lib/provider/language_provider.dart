import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('ml'), // Malayalam
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'ml': 'മലയാളം',
  };
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }
  
  /// Change language and save to SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    try {
      final newLocale = Locale(languageCode);
      
      if (supportedLocales.contains(newLocale) && _locale != newLocale) {
        _locale = newLocale;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }
  
  /// Get current language name
  String getCurrentLanguageName() {
    return languageNames[_locale.languageCode] ?? 'English';
  }
  
  /// Check if language is currently selected
  bool isLanguageSelected(String languageCode) {
    return _locale.languageCode == languageCode;
  }
  
  /// Get all available languages with their selection status
  List<Map<String, dynamic>> getAvailableLanguages() {
    return supportedLocales.map((locale) {
      return {
        'code': locale.languageCode,
        'name': languageNames[locale.languageCode] ?? locale.languageCode,
        'isSelected': isLanguageSelected(locale.languageCode),
      };
    }).toList();
  }
}