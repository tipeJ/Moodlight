import 'package:flutter/material.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:Moodlight/UI/screens/soundboard_moons_edit_add_screen.dart';
import 'package:Moodlight/main.dart';
import 'package:provider/provider.dart';

class SoundboardMoonsEditScreen extends StatelessWidget {
  const SoundboardMoonsEditScreen({Key? key}) : super(key: key);
  static const String routeName = 'soundboard_moons_edit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Consumer<SoundboardMoonsEditProvider>(
            builder: (context, value, child) {
              return value.soundboardMoonSounds.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        // Indicators for the soundboard moon buttons
                        Column(children: [
                          Container(
                              child: Center(
                                  child: Icon(Icons.nightlight_round_rounded)),
                              height: 75,
                              width: 75),
                          Container(
                              child: Icon(Icons.nightlight_sharp), height: 75),
                          Container(
                              child: Transform.rotate(
                                  angle: 3.14, child: Icon(Icons.mode_night)),
                              height: 75),
                          Container(child: Icon(Icons.circle), height: 75),
                          Container(child: Icon(Icons.mode_night), height: 75),
                          Container(
                              child: Transform.rotate(
                                  angle: 3.14,
                                  child: Icon(Icons.nightlight_sharp)),
                              height: 75),
                          Container(
                              child: Transform.rotate(
                                  angle: 3.14,
                                  child: Icon(Icons.nightlight_round_rounded)),
                              height: 75),
                        ]),
                        Expanded(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: ListView(
                                itemExtent: 75,
                                children: value.soundboardMoonSounds.indexed
                                    .toList()
                                    .map((sound) => InkWell(
                                        onTap: () async {
                                          // Launch the edit/add screen
                                          String? result = await mainNavigator
                                              .currentState!
                                              .pushNamed(
                                                  SoundboardScreenEditAddScreen
                                                      .routeName,
                                                  arguments: sound.$1);
                                          if (result != null) {
                                            await value.addSound(
                                                result, sound.$1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              value.getNameForFile(sound.$2)),
                                        ),
                                        key: ValueKey(sound.$1)))
                                    .toList()),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
