import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late List<GDPData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    List<GDPData> getChartData() {
      final List<GDPData> chartData = [
        //GDPData('Oceania', 1600),
        //GDPData('Africa', 2490),
        //GDPData('S America', 2900),
        GDPData('Hard', user!.hardQuestions),
        GDPData('Medium', user.mediumQuestions),
        GDPData('Easy', user.easyQuestions),
      ];
      return chartData;
    }

    _chartData = getChartData();

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
            title: AxisTitle(
                text: 'Number of questions ', textStyle: GoogleFonts.ptSans())),
      ),
    ));
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}
