import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:moodlight/UI/screens/screens.dart';
import 'package:moodlight/models/models.dart';
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
                    : Color.fromARGB(
                        Provider.of<LightingProvider>(context, listen: false)
                            .currentConfig!
                            .white,
                        Provider.of<LightingProvider>(context, listen: false)
                            .currentConfig!
                            .red,
                        Provider.of<LightingProvider>(context, listen: false)
                            .currentConfig!
                            .green,
                        Provider.of<LightingProvider>(context, listen: false)
                            .currentConfig!
                            .blue);
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
              red: result.red,
              green: result.green,
              blue: result.blue,
              white: result.alpha,
            ));
          },
          child: Container(
            width: 100,
            height: 100,
            color: Provider.of<LightingProvider>(context).currentConfig == null
                ? Colors.black
                : Color.fromARGB(
                    Provider.of<LightingProvider>(context).currentConfig!.white,
                    Provider.of<LightingProvider>(context).currentConfig!.red,
                    Provider.of<LightingProvider>(context).currentConfig!.green,
                    Provider.of<LightingProvider>(context).currentConfig!.blue),
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
      ],
    );
  }
}
