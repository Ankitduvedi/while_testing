// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:com.while.while_app/core/utils/containers_widgets/create_container.dart';
import 'package:com.while.while_app/data/model/numeric_model.dart';
import 'package:com.while.while_app/feature/upload/controller/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charts_flutter_new/flutter.dart' as charts_new;
import 'package:google_fonts/google_fonts.dart';

class MainCreatorScreen extends ConsumerStatefulWidget {
  const MainCreatorScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MainCreatorScreenState();
}

class _MainCreatorScreenState extends ConsumerState<MainCreatorScreen> {
  @override
  Widget build(BuildContext context) {
    final upload = ref.read(uploadControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            _buildCard(
                title: 'Dashboard',
                value: '63% ',
                text: 'more views',
                view: 'View increased from yesterday'),
            _buildCard(
                title: 'Revenue',
                value: '\$122.65 ',
                text: 'earned',
                view: 'Monthly'),
          ],
        ),
        // Followers and Likes
        Row(
          children: [
            _buildCard(title: 'Followers', value: '3,314'),
            _buildCard(title: 'Likes', value: '22.7k'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 200,
            child: charts_new.LineChart(_createSampleData()),
          ),
        ),
        CreateContainer(
            text: "Upload Video",
            function: () {
              upload.selectVideo(context, 'Video');
            }),
        CreateContainer(
            text: "Upload Loops",
            function: () {
              upload.selectVideo(context, 'Loop');
            }),
      ],
    );
  }
}

Widget _buildCard(
    {required String title,
    required String value,
    String? view,
    String? text}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Column(
            children: <Widget>[
              Text(
                title,
                style: GoogleFonts.ptSans(
                    fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: GoogleFonts.ptSans(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  if (text != null) Text(text),
                ],
              ),

              if (view != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 120,
                    child: charts_new.LineChart(_createSampleData()),
                  ),
                ),

              //Text(view!),
            ],
          ),
        ),
      ),
    ),
  );
}

List<charts_new.Series<MyNumericData, int>> _createSampleData() {
  final data = [
    MyNumericData(0, 3),
    MyNumericData(2, 2),
    MyNumericData(4, 5),
    MyNumericData(6, 3),
    MyNumericData(8, 4),
    MyNumericData(9, 3),
    MyNumericData(11, 4),
  ];

  return [
    charts_new.Series<MyNumericData, int>(
      id: 'Performance',
      colorFn: (_, __) => charts_new.MaterialPalette.blue.shadeDefault,
      domainFn: (MyNumericData sales, _) => sales.year,
      measureFn: (MyNumericData sales, _) => sales.sales,
      data: data,
    )
  ];
}
