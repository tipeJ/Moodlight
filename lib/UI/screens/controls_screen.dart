import 'dart:math';

import 'package:flutter/material.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:Moodlight/UI/screens/soundboard_moons_edit_screen.dart';
import 'package:Moodlight/UI/widgets/widgets.dart';
import 'package:Moodlight/main.dart';
import 'package:provider/provider.dart';
import 'package:Moodlight/resources/resources.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({Key? key}) : super(key: key);
  static const _powerButtonSizeRelativeToScreenWidth = 300.0;
  static const String routeName = 'controls';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<ConnectionProvider>(
          builder: (context, value, child) => value.connectedDevice != null &&
                  value.modeChar != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TemperatureChart(),
                    const Spacer(), // Spacer to push the buttons to the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brightness up/down buttons and powerbutton
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: Material(
                              color: Colors.blue, // button color
                              child: InkWell(
                                  splashColor: Colors.red, // inkwell color
                                  child: const SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(Icons.brightness_low)),
                                  onTap: () => value.setBrightnessValue('-1'),
                                  onLongPress: () =>
                                      value.setBrightnessValue("min")),
                            ),
                          ),
                        ),
                        ClipOval(
                          child: Material(
                            color: Colors.blue, // button color
                            child: InkWell(
                              child: SizedBox(
                                  width: min(
                                      MediaQuery.of(context).size.width -
                                          _powerButtonSizeRelativeToScreenWidth,
                                      _powerButtonSizeRelativeToScreenWidth),
                                  height: min(
                                      MediaQuery.of(context).size.width -
                                          _powerButtonSizeRelativeToScreenWidth,
                                      _powerButtonSizeRelativeToScreenWidth),
                                  child: Icon(
                                    Icons.power_settings_new,
                                    size: min(
                                        MediaQuery.of(context).size.width -
                                            _powerButtonSizeRelativeToScreenWidth,
                                        _powerButtonSizeRelativeToScreenWidth),
                                  )),
                              onTap: () {
                                value.sendPowerButton();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: Material(
                              color: Colors.blue, // button color
                              child: InkWell(
                                splashColor: Colors.red, // inkwell color
                                child: const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.brightness_high)),
                                onTap: () => value.setBrightnessValue('+1'),
                                onLongPress: () =>
                                    value.setBrightnessValue("max"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(), // Spacer to push the buttons to the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.only(
                                        left: 7.5,
                                        right: 10.0,
                                        top: 2.5,
                                        bottom: 2.5)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight:
                                      value.mode_value == MODE_SOUNDBOARD
                                          ? const Radius.circular(0.0)
                                          : const Radius.circular(20.0),
                                  topRight: value.mode_value == MODE_SOUNDBOARD
                                      ? const Radius.circular(0.0)
                                      : const Radius.circular(20.0),
                                )))),
                            onPressed: () {
                              value.toggle_mode_value();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 -
                                  (value.mode_value == MODE_SOUNDBOARD
                                      ? 68 + 5
                                      : 0),
                              child: Row(
                                children: [
                                  Icon(Icons.nightlight),
                                  Text(value.mode_value == MODE_LIGHTS
                                      ? "Lights"
                                      : "Soundboard"),
                                ],
                              ),
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        // Soundboard edit button
                        Visibility(
                          visible: value.mode_value == MODE_SOUNDBOARD,
                          child: SizedBox(
                            width: 68.0,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                )))),
                                onPressed: () {
                                  // Launch edit screen
                                  mainNavigator.currentState!.pushNamed(
                                      SoundboardMoonsEditScreen.routeName);
                                },
                                child: const Icon(Icons.edit, size: 20)),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              : Center(
                  // Display app icon if no device is connected
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      child: Image.asset(
                        'assets/icon/icon.png',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const GradientText(Text("Moodlight",
                        style: TextStyle(fontSize: 34, fontFamily: 'Pacifico')))
                  ],
                ))),
    );
  }
}
