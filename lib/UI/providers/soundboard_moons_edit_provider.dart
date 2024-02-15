import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Moodlight/resources/resources.dart';

// Class for editing the soundboard moon button sounds
class SoundboardMoonsEditProvider extends ChangeNotifier {
  static final Database _database = Database();

  // List of soundboard moon button sounds
  List<String> soundboardMoonSounds = [];
  final Map<String, Map<String, String>> soundFileToNameMapper = {};
  Map<String, String> _soundboardNames = {};

  SoundboardMoonsEditProvider() {
    // Load the soundboard moon button sounds from the database
    soundboardMoonSounds = _database.getSoundboardMoonSounds();
    _loadSounds();
  }

  void _loadSounds() async {
    // Load the asset "soundboard.txt" and split it into lines
    String sboard = await rootBundle.loadString('assets/soundboard.txt');
    List<String> sounds = sboard.split('\n');
    // Add the sounds to the mapper
    String latestCategory = '';
    for (String sound in sounds) {
      if (!sound.startsWith(' ')) {
        // If the line doesnt start with space, it's a category
        soundFileToNameMapper[sound] = {};
        latestCategory = sound;
      } else {
        // Add the sound to the latest category
        List<String> soundSplit = sound.split(':');
        soundFileToNameMapper[latestCategory]![soundSplit[1].trim()] =
            soundSplit[0].trim();
      }
    }
    // Collect the names of the sounds
    soundFileToNameMapper.forEach((key, value) {
      _soundboardNames.addAll(value);
    });
  }

  // Add a sound to the soundboard moon button sounds
  void addSound(String sound, int index) {
    soundboardMoonSounds[index] = sound;
    _database.setSoundboardMoonSound(sound, index);
    notifyListeners();
  }

  void reorderSounds(int oldIndex, int newIndex) {
    // Reorder the sounds
    String sound = soundboardMoonSounds[oldIndex];
    soundboardMoonSounds.removeAt(oldIndex);
    soundboardMoonSounds.insert(newIndex, sound);
    // Save the sounds to the database
    for (int i = 0; i < soundboardMoonSounds.length; i++) {
      _database.setSoundboardMoonSound(soundboardMoonSounds[i], i + 1);
    }
    notifyListeners();
  }

  String getNameForFile(String soundFile) {
    if (soundFile == '') {
      return 'None';
    }
    return _soundboardNames[soundFile] ?? '';
  }
}
