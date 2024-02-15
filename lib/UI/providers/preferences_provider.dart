import 'package:flutter/material.dart';
import 'package:Moodlight/resources/resources.dart';

class PreferencesProvider extends ChangeNotifier {
  static final Database _database = Database();

  bool isDarkMode() {
    return _database.isDarkMode();
  }

  void setDarkMode(bool value) {
    _database.setDarkMode(value);
    notifyListeners();
  }

  String defaultConnectionMACAddress() {
    return _database.defaultConnectionMACAddress();
  }

  void setDefaultConnectionMACAddress(String value) {
    _database.setDefaultConnectionMACAddress(value);
    notifyListeners();
  }

  bool automaticallyConnectToFirstSonatable() {
    return _database.automaticallyConnectToFirstSonatable();
  }

  void setAutomaticallyConnectToFirstSonatable(bool value) {
    _database.setAutomaticallyConnectToFirstSonatable(value);
    notifyListeners();
  }
}
