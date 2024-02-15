import 'dart:math';

import 'package:Moodlight/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:Moodlight/resources/constants.dart';
import 'package:provider/provider.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:Moodlight/models/models.dart';

class TemperatureChart extends StatefulWidget {
  TemperatureChart({super.key});

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  ChartSeriesController? _chartSeriesController;
  List<TemperatureData> temperatureHistory = [];
  ConnectionProvider? connectionProvider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    connectionProvider = context.read<ConnectionProvider>();
  }

  @override
  void dispose() {
    connectionProvider?.removeListener(_updateChart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.all(15.0),
      child: SfCartesianChart(
        margin: const EdgeInsets.all(15.0),
        primaryXAxis: const CategoryAxis(isVisible: false),
        plotAreaBorderColor: Colors.transparent,
        primaryYAxis: NumericAxis(
          minimum: temperatureHistory.isEmpty
              ? 10
              : max(
                  10,
                  temperatureHistory
                          .map((temperature) => temperature.temperature)
                          .reduce(min) -
                      0.2),
          maximum: temperatureHistory.isEmpty
              ? 30
              : min(
                  60,
                  temperatureHistory
                          .map((temperature) => temperature.temperature)
                          .reduce(max) +
                      0.2),
          // interval: 1,
          labelFormat: '{value}°C',
        ),
        title: ChartTitle(
            text:
                'Current Temperature: ${temperatureHistory.isEmpty ? 0 : temperatureHistory.last.temperature}°C'),
        enableAxisAnimation: true,
        series: <AreaSeries<TemperatureData, String>>[
          AreaSeries<TemperatureData, String>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            color: Theme.of(context).primaryColor,
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MOODLIGHT_COLOR_2.withOpacity(0.75),
                  MOODLIGHT_COLOR_3.withOpacity(0.75)
                ]),
            animationDuration: 500,
            dataSource: temperatureHistory,
            xValueMapper: (TemperatureData temperature, _) => temperature.time,
            yValueMapper: (TemperatureData temperature, _) =>
                temperature.temperature,
            name: 'Temperature',
          )
        ],
      ),
    );
  }
}
