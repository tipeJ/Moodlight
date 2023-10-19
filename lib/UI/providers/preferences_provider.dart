import 'package:flutter/material.dart';
import 'package:moodlight/resources/resources.dart';

class PreferencesProvider extends ChangeNotifier {
  static final Database _database = Database();

  bool isDarkMode() {
    return _database.isDarkMode();
  }

  void setDarkMode(bool value) {
    _database.setDarkMode(value);
    notifyListeners();
  }
}