import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<GDPData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SfCartesianChart(
        title: ChartTitle(text: 'Number of Questions - 2024'),
        legend: Legend(isVisible: true),
        tooltipBehavior: _tooltipBehavior,
        series: <ChartSeries>[
          BarSeries<GDPData, String>(
              name: 'Questions',
              dataSource: _chartData,
              xValueMapper: (GDPData gdp, _) => gdp.continent,
              yValueMapper: (GDPData gdp, _) => gdp.gdp,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true)
        ],
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            numberFormat: NumberFormat.compact(),
            title: AxisTitle(text: 'Number of questions ')),
      ),
    ));
  }

  List<GDPData> getChartData() {
    final List<GDPData> chartData = [
      //GDPData('Oceania', 1600),
      //GDPData('Africa', 2490),
      //GDPData('S America', 2900),
      GDPData('Hard', APIs.me.hardQuestions),
      GDPData('Medium', APIs.me.mediumQuestions),
      GDPData('Easy', APIs.me.easyQuestions),
    ];
    return chartData;
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}
