import 'dart:developer';

import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:provider/provider.dart';
import 'package:com.example.while_app/resources/components/create_container.dart';
import 'package:com.example.while_app/view_model/post_provider.dart';
import 'package:com.example.while_app/view_model/reel_controller.dart';
import 'package:charts_flutter_new/flutter.dart' as charts_new;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateScreen extends river.ConsumerStatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  river.ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends river.ConsumerState<CreateScreen> {
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    APIs.getSelfInfo();
    super.initState();
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(APIs.me.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReelController>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Studio',
            style: GoogleFonts.ptSans(color: Colors.lightBlueAccent)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: getUserStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: Text("Error fetching data"));
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            bool isContentCreator = userData['isContentCreator'] ?? false;
            bool isApproved = userData['isApproved'] ?? false;

            if (!isContentCreator && !isApproved) {
              return becomeCreatorScreen();
            } else if (!isContentCreator && isApproved) {
              return underReviewScreen();
            } else {
              return maincontent(provider, postProvider);
            }
          },
        ),
      ),
    );
  }

  Widget underReviewScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your request is under review',
              style: GoogleFonts.ptSans(
                  color: Colors.lightBlueAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Thank you for submitting your request to become a creator. We're currently reviewing your submission and will notify you once the process is complete.",
              style: GoogleFonts.ptSans(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget maincontent(provider, postProvider) {
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
              provider.selectVideo(context, 'Video');
            }),
        CreateContainer(
            text: "Upload Loops",
            function: () {
              provider.selectVideo(context, 'Loop');
            }),
        CreateContainer(
            text: "Upload Post",
            function: () {
              postProvider.selectPost(context);
            }),
      ],
    );
  }

  Widget becomeCreatorScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Become Creator',
            style: GoogleFonts.ptSans(
                color: Colors.lightBlueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _instagramController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Instagram Link',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _youtubeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'YouTube Link',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Add your submission logic here
              await APIs.submitCreatorRequest(
                  context: context,
                  userId: APIs.me.id,
                  instagramLink: _instagramController.text.trim(),
                  youtubeLink: _youtubeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  /// Create one series with sample hard-coded data.
  static List<charts_new.Series<MyNumericData, int>> _createSampleData() {
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
}

/// Sample numeric data type.
class MyNumericData {
  final int year;
  final int sales;

  MyNumericData(this.year, this.sales);
}
