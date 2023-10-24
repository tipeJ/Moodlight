import 'package:flutter/material.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:moodlight/resources/resources.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<ConnectionProvider>(
          builder: (context, value, child) =>
              value.connectedDevice != null && value.modeChar != null
                  ? Column(
                      children: [
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
