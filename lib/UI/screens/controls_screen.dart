import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:moodlight/resources/resources.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({Key? key}) : super(key: key);
  static const _powerButtonSizeRelativeToScreenWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<ConnectionProvider>(
          builder: (context, value, child) =>
              value.connectedDevice != null && value.modeChar != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular button for power
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
                                        child: Icon(Icons.light_mode)),
                                    onTap: () {
                                      value.setBrightnessValue('-1');
                                    },
                                  ),
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
                                        child: Icon(Icons.light_mode_outlined)),
                                    onTap: () {
                                      value.setBrightnessValue('+1');
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              value.toggle_mode_value();
                            },
                            child: Text(value.mode_value == MODE_LIGHTS
                                ? "Lights"
                                : "Soundboard")),
                      ],
                    )
                  : const SizedBox()),
    );
  }
}
