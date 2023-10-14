import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:moodlight/models/models.dart';
import 'package:moodlight/util/utils.dart';
import 'package:provider/provider.dart';

class LightingProvider extends ChangeNotifier {
  SolidLightConfiguration? currentConfig;

  void set_light_config(SolidLightConfiguration config) {
    currentConfig = config;
    notifyListeners();
  }
}

class LightingScreen extends StatelessWidget {
  const LightingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rectangle showing the current color
        GestureDetector(
          onTap: () async {
            Color preColor =
                Provider.of<LightingProvider>(context, listen: false)
                            .currentConfig ==
                        null
                    ? Colors.black
                    : Provider.of<LightingProvider>(context, listen: false)
                        .currentConfig!
                        .color;
            // Use FlutterColorPicker to select a color
            Color? result = await showDialog(
                context: context,
                builder: ((context) {
                  Color _currentColor = preColor;
                  return AlertDialog(
                    title: const Text("Pick a color"),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: preColor,
                        labelTypes: const [ColorLabelType.hsl],
                        onColorChanged: (color) {
                          _currentColor = color;
                        },
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(_currentColor);
                          },
                          child: const Text("Close"))
                    ],
                  );
                }));

            if (result == null) return;
            Provider.of<LightingProvider>(context, listen: false)
                .set_light_config(SolidLightConfiguration(
              color: result,
            ));
          },
          child: Container(
            width: 100,
            height: 100,
            color: Provider.of<LightingProvider>(context).currentConfig == null
                ? Colors.black
                : Provider.of<LightingProvider>(context).currentConfig!.color,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Provider.of<ConnectionProvider>(context, listen: false)
                  .send_light_setting(
                      Provider.of<LightingProvider>(context, listen: false)
                          .currentConfig!);
            },
            child: Text("Set color")),

        ElevatedButton(
            onPressed: () {
              Provider.of<ConnectionProvider>(context, listen: false)
                  .send_light_setting(RainbowLightConfiguration(waitMS: 2));
            },
            child: const Text("Set Rainbow"))
      ],
    );
  }
}
