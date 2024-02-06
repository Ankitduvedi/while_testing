import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/controller/videos_lists.dart';
import 'package:com.example.while_app/data/model/video_model.dart';
import 'package:com.example.while_app/main.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view/profile/creators_reels_screen.dart';
import 'package:http/http.dart' as http;

class CreatorProfile extends StatelessWidget {
  CreatorProfile({super.key, required this.userID});
  final String userID;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('videos')
            .where('uploadedBy', isEqualTo: userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<String> imageUrls = snapshot.data!.docs
              .map((doc) => doc['thumbnail'].toString())
              .toList();

          return ListView.builder(
            scrollDirection: Axis.vertical, // Make the list scroll horizontally
            itemCount:
                (imageUrls.length / 2).ceil(), // Calculate the number of rows
            itemBuilder: (context, rowIndex) {
              int startIndex = rowIndex * 2;
              int endIndex = startIndex + 2;
              final List<Video> videoList =
                  VideoList.getVideoList(snapshot.data!);

              // Ensure endIndex is within bounds
              if (endIndex > imageUrls.length) {
                endIndex = imageUrls.length;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  endIndex - startIndex,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                          onLongPress: () {
                            final String id = snapshot.data!.docs[index].id;
                            _showOptionsDialog(context, id);
                          },
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CreatorReelsScreen(
                                      video: videoList[startIndex + index],
                                      index: 0,
                                    )));
                          },
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(mq.height * .13),
                            child: CachedNetworkImage(
                              width: mq.width / 2.1,
                              fit: BoxFit.cover,
                              height: mq.height / 3,
                              imageUrl: imageUrls[startIndex + index],
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      child: Icon(CupertinoIcons.person)),
                            ),
                          )),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, String id) {
    final Uri uri =
        Uri.parse('https://sandbox.api.video/videos/vi1n0cJIAJLommOiqmqPGvhm');
    const String apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define the initial dialog content with predefined buttons
        Widget initialDialogContent = AlertDialog(
          title: const Text('Choose an Option'),
          content: const SizedBox(
            height: 45,
            width: 0,
            child: Center(
              child: CircularProgressIndicator(
                value: null,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform the action for Option 1
              },
              child: const Text('Option 1'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform the action for Option 2
              },
              child: const Text('Option 2'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                APIs.deleteReel(id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );

        // Use a FutureBuilder to fetch data in the background
        return FutureBuilder(
          future: http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              // Add other headers if needed
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Data is still being fetched, show the initial dialog content
              return initialDialogContent;
            } else if (snapshot.hasError) {
              // Error while fetching data, show an error dialog
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to fetch data: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              // Data does not exist, show an error dialog
              return const AlertDialog(
                title: Text('Error'),
                content: Text('Data does not exist.'),
              );
            } else {
              // Data is fetched successfully, update the dialog content
              var data = json.decode(snapshot.data!.body);
              String title = data['title'] ?? "No Title";
              String description = data['description'] ?? "No Description";
              int views = data['views'] ?? 1000;
              DateTime uploadedAt = DateTime.parse(data['createdAt']);

              return AlertDialog(
                title: const Hero(
                  tag: 'dialog-title', // Use a unique tag for the Hero widget
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text('Choose an Option',
                        style:
                            TextStyle(fontSize: 16.0)), // Set a fixed text size
                  ),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag:
                          'dialog-content', // Use a unique tag for the Hero widget
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Title: $title',
                                style: const TextStyle(
                                    fontSize: 14.0)), // Set a fixed text size
                            Text('Description: $description',
                                style: const TextStyle(
                                    fontSize: 14.0)), // Set a fixed text size
                            Text('Views: $views',
                                style: const TextStyle(
                                    fontSize: 14.0)), // Set a fixed text size
                            Text('Uploaded At: ${uploadedAt.toString()}',
                                style: const TextStyle(
                                    fontSize: 14.0)), // Set a fixed text size
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Perform the action for Option 1
                    },
                    child: const Text('Option 1'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Perform the action for Option 2
                    },
                    child: const Text('Option 2'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      APIs.deleteReel(id);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
