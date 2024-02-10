import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moodlight/resources/constants.dart';
import 'package:provider/provider.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:moodlight/models/models.dart';

class TemperatureChart extends StatefulWidget {
  TemperatureChart({super.key});

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  ChartSeriesController? _chartSeriesController;
  List<TemperatureData> temperatureHistory = [];

  @override
  void initState() {
    super.initState();
    temperatureHistory = context.read<ConnectionProvider>().temperatureHistory;
    context.read<ConnectionProvider>().addListener(_updateChart);
  }

  void _updateChart() {
    final int temperatureHistoryLen =
        context.read<ConnectionProvider>().temperatureHistory.length;
    temperatureHistory = context
        .read<ConnectionProvider>()
        .temperatureHistory
        .sublist(max(
            0,
            context.read<ConnectionProvider>().temperatureHistory.length -
                MAX_TEMPERATURE_HISTORY_LENGTH));
    if (_chartSeriesController != null &&
        temperatureHistoryLen >= MAX_TEMPERATURE_HISTORY_LENGTH) {
      setState(() {
        _chartSeriesController!.updateDataSource(
          addedDataIndex: MAX_TEMPERATURE_HISTORY_LENGTH - 1,
          removedDataIndex: 0,
        );
      });
    }
  }

  @override
  void dispose() {
    context.read<ConnectionProvider>().removeListener(_updateChart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: const EdgeInsets.all(15.0),
      primaryXAxis: const CategoryAxis(isVisible: false),
      primaryYAxis: NumericAxis(
        minimum: temperatureHistory.isEmpty
            ? 10
            : max(
                10,
                temperatureHistory
                        .map((temperature) => temperature.temperature)
                        .reduce(min) -
                    2),
        maximum: temperatureHistory.isEmpty
            ? 30
            : min(
                60,
                temperatureHistory
                        .map((temperature) => temperature.temperature)
                        .reduce(max) +
                    2),
        // interval: 1,
        labelFormat: '{value}°C',
      ),
      title: const ChartTitle(text: 'Temperature'),
      enableAxisAnimation: true,
      series: <LineSeries<TemperatureData, String>>[
        LineSeries<TemperatureData, String>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            animationDuration: 500,
            dataSource: temperatureHistory,
            xValueMapper: (TemperatureData temperature, _) => temperature.time,
            yValueMapper: (TemperatureData temperature, _) =>
                temperature.temperature,
            name: 'Temperature')
      ],
    );
  }
}
