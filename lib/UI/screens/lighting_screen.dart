import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:moodlight/models/models.dart';
import 'package:moodlight/util/utils.dart';
import 'package:provider/provider.dart';

class LightingProvider extends ChangeNotifier {
  SolidLightConfiguration? currentConfig;
  List<LightConfiguration> configs = [];
  // Which config is selected for editing
  int selectedConfig = 0;
  LightConfiguration get selectedConfiguration => configs[selectedConfig];

  LightingProvider() {
    configs = [
      SolidLightConfiguration.defaultConfig,
      RainbowLightConfiguration.defaultConfig,
      GradientPulseConfiguration.defaultConfig
    ];
  }

  void changeSelection(int index) {
    selectedConfig = index;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}

class LightingScreen extends StatelessWidget {
  const LightingScreen({Key? key}) : super(key: key);

  Widget _getDescriptionTile(BuildContext context, LightConfiguration config) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(config.description),
    ));
  }

  List<Widget> _getSliversForConfig(
      BuildContext context, LightConfiguration config) {
    switch (config.runtimeType) {
      case RainbowLightConfiguration:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text("Wait time (ms)"),
                  Expanded(
                    child: Slider(
                      value:
                          (Provider.of<LightingProvider>(context, listen: false)
                                      .selectedConfiguration
                                  as RainbowLightConfiguration)
                              .waitMS
                              .toDouble(),
                      min: 1,
                      max: 1000,
                      divisions: 1000,
                      label:
                          (Provider.of<LightingProvider>(context, listen: false)
                                      .selectedConfiguration
                                  as RainbowLightConfiguration)
                              .waitMS
                              .toString(),
                      onChanged: (value) {
                        (Provider.of<LightingProvider>(context, listen: false)
                                    .selectedConfiguration
                                as RainbowLightConfiguration)
                            .waitMS = value.toInt();
                        Provider.of<LightingProvider>(context, listen: false)
                            .refresh();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      case SolidLightConfiguration:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                  enableAlpha: false,
                  pickerAreaHeightPercent: 0.8,
                  pickerColor:
                      (Provider.of<LightingProvider>(context, listen: false)
                              .selectedConfiguration as SolidLightConfiguration)
                          .color,
                  onColorChanged: (value) =>
                      (Provider.of<LightingProvider>(context, listen: false)
                              .selectedConfiguration as SolidLightConfiguration)
                          .color = value),
            ),
          ),
        ];
      case GradientPulseConfiguration:
        return [
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("Wait time (ms)"),
                    Expanded(
                      child: Slider(
                        value: (Provider.of<LightingProvider>(context,
                                        listen: false)
                                    .selectedConfiguration
                                as GradientPulseConfiguration)
                            .waitMS
                            .toDouble(),
                        min: 1,
                        max: 1000,
                        divisions: 1000,
                        label: (Provider.of<LightingProvider>(context,
                                        listen: false)
                                    .selectedConfiguration
                                as GradientPulseConfiguration)
                            .waitMS
                            .toString(),
                        onChanged: (value) {
                          (Provider.of<LightingProvider>(context, listen: false)
                                      .selectedConfiguration
                                  as GradientPulseConfiguration)
                              .waitMS = value.toInt();
                          Provider.of<LightingProvider>(context, listen: false)
                              .refresh();
                        },
                      ),
                    ),
                  ],
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("Steps"),
                    Expanded(
                      child: Slider(
                        value: (Provider.of<LightingProvider>(context,
                                        listen: false)
                                    .selectedConfiguration
                                as GradientPulseConfiguration)
                            .steps
                            .toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 100,
                        label: (Provider.of<LightingProvider>(context,
                                        listen: false)
                                    .selectedConfiguration
                                as GradientPulseConfiguration)
                            .steps
                            .toString(),
                        onChanged: (value) {
                          (Provider.of<LightingProvider>(context, listen: false)
                                      .selectedConfiguration
                                  as GradientPulseConfiguration)
                              .steps = value.toInt();
                          Provider.of<LightingProvider>(context, listen: false)
                              .refresh();
                        },
                      ),
                    ),
                  ],
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                  enableAlpha: false,
                  pickerAreaHeightPercent: 0.8,
                  pickerColor:
                      (Provider.of<LightingProvider>(context, listen: false)
                                  .selectedConfiguration
                              as GradientPulseConfiguration)
                          .color1,
                  onColorChanged: (value) =>
                      (Provider.of<LightingProvider>(context, listen: false)
                                  .selectedConfiguration
                              as GradientPulseConfiguration)
                          .color1 = value),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                  enableAlpha: false,
                  pickerAreaHeightPercent: 0.8,
                  pickerColor:
                      (Provider.of<LightingProvider>(context, listen: false)
                                  .selectedConfiguration
                              as GradientPulseConfiguration)
                          .color2,
                  onColorChanged: (value) =>
                      (Provider.of<LightingProvider>(context, listen: false)
                                  .selectedConfiguration
                              as GradientPulseConfiguration)
                          .color2 = value),
            ),
          ),
        ];
      default:
        return [
          const SliverToBoxAdapter(
            child: Text("Unknown config!"),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    items: Provider.of<LightingProvider>(context, listen: false)
                        .configs
                        .asMap()
                        .entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value.name),
                            ))
                        .toList(),
                    value:
                        Provider.of<LightingProvider>(context).selectedConfig,
                    onChanged: (value) => {
                      Provider.of<LightingProvider>(context, listen: false)
                          .changeSelection(value!)
                    },
                  ),
                ),
              ),
              _getDescriptionTile(context,
                  Provider.of<LightingProvider>(context).selectedConfiguration),
              ..._getSliversForConfig(context,
                  Provider.of<LightingProvider>(context).selectedConfiguration),
              // Spacer for the floating button
              const SliverToBoxAdapter(
                  child: SizedBox(
                height: 100,
              ))
            ],
          ),
          // Floating button to send the current config
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 75,
                child: Consumer<ConnectionProvider>(
                  builder: (context, provider, child) => ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              provider.isConnected()
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey)),
                      onPressed: provider.isConnected()
                          ? () {
                              provider.sendLightConfig(
                                  Provider.of<LightingProvider>(context,
                                          listen: false)
                                      .selectedConfiguration);
                            }
                          : null,
                      child: const Text("Set Light Config!")),
                ),
              ))
        ],
      ),
    );
  }
}
