import 'dart:math';

import 'package:Moodlight/UI/providers/providers.dart';
import 'package:Moodlight/UI/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Moodlight/resources/resources.dart';

class SoundBoardScreenMoonButtonsWrapper extends StatelessWidget {
  final Widget child;
  const SoundBoardScreenMoonButtonsWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrapper for the soundboard screen, adds the EXPANDABLE FAB, which will show 7 buttons
    return Scaffold(
      body: child,
      floatingActionButton: ExpandableFab(
        distance: 200.0,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 1);
              },
              icon: const Icon(Icons.music_note),
            ),
          ),
          CircleAvatar(
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 2);
              },
              icon: const Icon(Icons.brightness_3),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 3);
              },
              icon: const Icon(Icons.music_note),
            ),
          ),
          CircleAvatar(
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 4);
              },
              icon: const Icon(Icons.brightness_3),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 5);
              },
              icon: const Icon(Icons.music_note),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 6);
                Navigator.of(context).pushNamed('soundboard');
              },
              icon: const Icon(Icons.music_note),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: () {
                handle_button_click(MODE_SOUNDBOARD, 7);
              },
              icon: const Icon(Icons.music_note),
            ),
          ),
        ],
      ),
    );
  }
}

class SoundBoardScreen extends StatelessWidget {
  const SoundBoardScreen({Key? key}) : super(key: key);
  static const String routeName = 'soundboard';

  @override
  Widget build(BuildContext context) {
    // Read the files from assets/sounds directory
    final screen_width = MediaQuery.of(context).size.width;
    return Material(
      child: FutureBuilder<List<String>>(
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
          }),
    );
  }
}

class SoundBoardCategoryScreen extends StatelessWidget {
  const SoundBoardCategoryScreen({Key? key, required this.category})
      : super(key: key);
  final String category;

  @override
  Widget build(BuildContext context) {
    // Read the files from assets/sounds directory
    return Material(
      child: FutureBuilder<List<String>>(
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
                      child: Row(
                        children: [
                          // Back button
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Expanded(
                            child: Text(
                              category,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  int index = i - 1;
                  final name = snapshot.data![index].split(':')[0];
                  final soundFile = snapshot.data![index].split(':')[1];
                  return Container(
                    color: index % 2 == 0
                        ? Colors.black.withOpacity(0.1)
                        : Colors.transparent,
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
          }),
    );
  }
}
