import 'package:flutter/material.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:Moodlight/resources/resources.dart';
import 'package:provider/provider.dart';

class SoundboardScreenEditAddScreen extends StatelessWidget {
  final int soundID;
  const SoundboardScreenEditAddScreen({Key? key, required this.soundID})
      : super(key: key);

  static const String routeName = 'soundboard_edit_add';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<SoundboardMoonsEditProvider>(
        // Build the category and sound list from the provider map
        builder: (context, value, child) {
      List<((String, String), bool)> categoriesAndSounds = [];
      for (var category in value.soundFileToNameMapper.keys) {
        categoriesAndSounds.add((('', category), false));
        print(category);
        for (var sound
            in value.soundFileToNameMapper[category]!.entries.toList()) {
          categoriesAndSounds.add(((sound.key, sound.value), true));
          print(sound);
        }
      }
      return ListView.builder(
        itemCount: categoriesAndSounds.length,
        itemBuilder: (context, index) => categoriesAndSounds[index].$2
            ? ListTile(
                // Item
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    categoriesAndSounds[index].$1.$2,
                  ),
                ),
                onTap: () {
                  if (categoriesAndSounds[index].$2) {
                    SoundboardPlayer()
                        .playSound(categoriesAndSounds[index].$1.$1);
                  }
                },
                trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(categoriesAndSounds[index].$1.$1);
                      if (categoriesAndSounds[index].$2) {}
                    },
                    icon: const Icon(Icons.approval)),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  // Category
                  categoriesAndSounds[index].$1.$2.split(':')[0],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Theme.of(context).secondaryHeaderColor),
                ),
              ),
      );
    }));
  }
}
