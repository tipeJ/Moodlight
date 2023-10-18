import 'package:hive/hive.dart';

class Database {
  static final Database _singleton = Database._internal();
  late final Box _preferencesBox;
  late final Box _soundBoardBox;

  Future<void> init() async {
    _preferencesBox = await Hive.openBox('preferences');
    _soundBoardBox = await Hive.openBox('soundboard');
  }

  factory Database() {
    return _singleton;
  }

  Database._internal();

  static Future<void> close() async {
    await Hive.close();
  }

  // Getters and setters for preferences
  bool isDarkMode() {
    return _preferencesBox.get('darkMode', defaultValue: false);
  }

  void setDarkMode(bool value) {
    _preferencesBox.put('darkMode', value);
  }
}
