import 'package:audioplayers/audioplayers.dart';

class SoundboardPlayer {
  static final SoundboardPlayer _singleton = SoundboardPlayer._internal();
  final player = AudioPlayer();

  factory SoundboardPlayer() {
    return _singleton;
  }

  SoundboardPlayer._internal();

  Future<void> playSound(String soundFile) async {
    // If the player is currently
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource('sounds/${soundFile.trim()}'), volume: 1.0);
  }
}
