import 'dart:developer';

import 'package:com.while.while_app/core/utils/containers_widgets/create_container.dart';
import 'package:com.while.while_app/data/model/numeric_model.dart';
import 'package:com.while.while_app/feature/upload/controller/upload_controller.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
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
    log('main screen');
    final upload = ref.read(uploadControllerProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              _buildCard(
                  title: 'Views', value: 'No Data', view: 'View increased '),
              _buildCard(title: 'Revenue', value: 'No Data', view: 'Monthly'),
            ],
          ),
          Row(
            children: [
              _buildCard(
                  title: 'Followers',
                  value: ref
                      .watch(userDataProvider)
                      .userData!
                      .follower
                      .toString()),
              _buildCard(title: 'Likes', value: 'No Data'),
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
            },
            // backgroundColor: Colors.blueAccent,
            // textColor: Colors.white,
          ),
          const SizedBox(height: 10),
          CreateContainer(
            text: "Upload Loops",
            function: () {
              upload.selectVideo(context, 'Loop');
            },
            // backgroundColor: Colors.green,
            // textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

Widget _buildCard({
  required String title,
  required String value,
  String? view,
  String? text,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: GoogleFonts.ptSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.ptSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (text != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        text,
                        style: GoogleFonts.ptSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
              if (view != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    view,
                    style: GoogleFonts.ptSans(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
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
    ),
  ];
}
