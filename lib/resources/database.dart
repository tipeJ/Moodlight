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

  String defaultConnectionMACAddress() {
    return _preferencesBox.get('defaultConnectionMACAddress', defaultValue: '');
  }

  void setDefaultConnectionMACAddress(String value) {
    _preferencesBox.put('defaultConnectionMACAddress', value);
  }

  bool automaticallyConnectToFirstSonatable() {
    return _preferencesBox.get('automaticallyConnectToFirstSonatable',
        defaultValue: false);
  }

  void setAutomaticallyConnectToFirstSonatable(bool value) {
    _preferencesBox.put('automaticallyConnectToFirstSonatable', value);
  }

  List<String> getSoundboardMoonSounds() {
    // Get all sounds, from 1 to 7
    List<String> sounds = [];
    for (int i = 0; i <= 6; i++) {
      sounds.add(_soundBoardBox.get('sound$i', defaultValue: ''));
    }
    return sounds;
  }

  String getSoundAt(int index) {
    return _soundBoardBox.get('sound$index', defaultValue: '');
  }

  Future<void> setSoundboardMoonSound(String sound, int index) async {
    // Replace old value
    await _soundBoardBox.delete('sound$index');
    await _soundBoardBox.put('sound$index', sound);
  }
}
