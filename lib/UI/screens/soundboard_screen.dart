import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:moodlight/resources/resources.dart';

class SoundBoardScreen extends StatelessWidget {
  const SoundBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read the files from assets/sounds directory
    final screen_width = MediaQuery.of(context).size.width;
    return FutureBuilder<List<String>>(
        future: DefaultAssetBundle.of(context)
            .loadString('assets/soundboard.txt', cache: false)
            .then((value) =>
                value.split('\n').where((e) => !e.startsWith(' ')).toList()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
                crossAxisCount: 2,
                children: List.generate(snapshot.data!.length, (index) {
                  final split = snapshot.data![index].split(':');
                  final name = split[0];
                  final image = split[1];
                  return Container(
                    width: screen_width / 3,
                    height: screen_width / 3,
                    margin: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            Navigator.of(context).pushNamed(
                                'soundboardCategory',
                                arguments: name);
                          },
                          child: Image.asset(
                            'assets/images/${image.trim()}',
                            fit: BoxFit.cover,
                          )),
                    ),
                  );
                }));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const SizedBox();
        });
  }
}

class SoundBoardCategoryScreen extends StatelessWidget {
  const SoundBoardCategoryScreen({Key? key, required this.category})
      : super(key: key);
  final String category;

  @override
  Widget build(BuildContext context) {
    // Read the files from assets/sounds directory
    return FutureBuilder<List<String>>(
        // Find first non-spaced line that matches the category, then read all lines until the next category
        future: DefaultAssetBundle.of(context)
            .loadString('assets/soundboard.txt')
            .then((value) => value
                .split('\n')
                .skipWhile((e) => !e.startsWith(category))
                .skip(1)
                .takeWhile((e) => e.startsWith(' '))
                .toList()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                }
                int index = i - 1;
                final name = snapshot.data![index].split(':')[0];
                final soundFile = snapshot.data![index].split(':')[1];
                return Container(
                  color: index % 2 == 0
                      ? Colors.black.withOpacity(0.1)
                      : Colors.white,
                  child: ListTile(
                    title: Text(name),
                    onTap: () async {
                      SoundboardPlayer().playSound(soundFile);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const SizedBox();
        });
  }
}
