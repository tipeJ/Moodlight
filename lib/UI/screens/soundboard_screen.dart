import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// The view for the main screen, using ConnectionProvider
class SoundBoardScreen extends StatelessWidget {
  const SoundBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read the files from assets/sounds directory
    final player = AudioPlayer();
    return FutureBuilder<List<String>>(
        future: DefaultAssetBundle.of(context)
            .loadString('assets/soundboard.txt')
            .then((value) => value.split('\n')),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
                crossAxisCount: 2,
                children: List.generate(snapshot.data!.length, (index) {
                  final split = snapshot.data![index].split(':');
                  final soundFile = split[0];
                  final soundImage = split[1];
                  return Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            await player.play(AssetSource('sounds/$soundFile'),
                                volume: 1.0);
                          },
                          child: Image(
                              image: AssetImage('assets/images/$soundImage'))));
                }));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const SizedBox();
        });
  }
}
