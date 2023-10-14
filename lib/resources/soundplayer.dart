import 'package:audioplayers/audioplayers.dart';

class SoundboardPlayer {
  static final SoundboardPlayer _singleton = SoundboardPlayer._internal();
  final player = AudioPlayer();

  factory SoundboardPlayer() {
    return _singleton;
  }

  SoundboardPlayer._internal();

  Future<void> playSound(String soundFile) async {
    await player.play(AssetSource('sounds/$soundFile'), volume: 1.0);
  }
}
