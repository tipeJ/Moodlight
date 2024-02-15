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
        itemBuilder: (context, index) => ListTile(
          title: Text(categoriesAndSounds[index].$1.$2,
              style: TextStyle(
                fontSize: categoriesAndSounds[index].$2 ? 16 : 20,
              )),
          onTap: () {
            if (categoriesAndSounds[index].$2) {
              SoundboardPlayer().playSound(categoriesAndSounds[index].$1.$1);
            }
          },
          trailing: IconButton(
              onPressed: () {
                if (categoriesAndSounds[index].$2) {
                  Navigator.of(context).pop(categoriesAndSounds[index].$1.$1);
                }
              },
              icon: const Icon(Icons.approval)),
        ),
      );
    }));
  }
}
