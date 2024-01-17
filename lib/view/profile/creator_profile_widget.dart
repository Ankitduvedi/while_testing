import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:while_app/controller/videos_lists.dart';
import 'package:while_app/data/model/video_model.dart';
import 'package:while_app/main.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/view/profile/creators_reels_screen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class CreatorProfile extends StatelessWidget {
  CreatorProfile({super.key, required this.userID});
  final String userID;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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

  // void _showOptionsDialog(BuildContext context, String id) {
  //   final StreamController<DocumentSnapshot<Map<String, dynamic>>> _controller =
  //     StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       http.get(Uri.parse('https://sandbox.api.video/videos/vi1n0cJIAJLommOiqmqPGvhm'))
  //           .then((response) {
  //         if (response.statusCode == 200) {
  //           final Map<String, dynamic> data = json.decode(response.body);
  //           _controller.add(DocumentSnapshot<Map<String, dynamic>>(
  //             data: data,
  //             exists: true,
  //             reference: null, // You can provide a proper reference if needed
  //           ));
  //         } else {
  //           _controller.addError('Failed to fetch data.');
  //         }
  //       }).catchError((error) {
  //         _controller.addError('Failed to fetch data: $error');
  //       });

  //       return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  //         stream: _controller.stream,
  //         builder: (context, snapshot) {
  //           if (snapshot.hasError) {
  //             return AlertDialog(
  //               title: const Text('Error'),
  //               content: Text('Failed to fetch data: ${snapshot.error}'),
  //             );
  //           }

  //           if (!snapshot.hasData || !snapshot.data!.exists) {
  //             return AlertDialog(
  //               title: const Text('Error'),
  //               content: const Text('Data does not exist.'),
  //             );
  //           }

  //           var data = snapshot.data!.data();
  //           String title = data!['title'] ?? "No Title";
  //           String description = data['description'] ?? "No Description";
  //           int views = data['views'] ?? 0;
  //           DateTime uploadedAt =
  //               (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

  //           return AlertDialog(
  //             title: const Text('Choose an Option'),
  //             content: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text('Title: $title'),
  //                 Text('Description: $description'),
  //                 Text('Views: $views'),
  //                 Text('Uploaded At: ${uploadedAt.toString()}'),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   // Perform the action for Option 1
  //                 },
  //                 child: const Text('Option 1'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   // Perform the action for Option 2
  //                 },
  //                 child: const Text('Option 2'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   // APIs.deleteReel(id);
  //                   // Perform the action for Delete
  //                 },
  //                 style: TextButton.styleFrom(
  //                   foregroundColor: Colors
  //                       .red, // Change the text color to red for delete option
  //                 ),
  //                 child: const Text('Delete'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void _showOptionsDialog(BuildContext context, String id) {
    final Uri uri =
        Uri.parse('https://sandbox.api.video/videos/vi1n0cJIAJLommOiqmqPGvhm');
    const String apiKey =
        'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6'; // replace with your actual API key
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              // Add other headers if needed
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const AlertDialog(
                title: Text('Error'),
                content: Text('Failed to fetch data.'),
              );
            }

            if (!snapshot.hasData) {
              return const AlertDialog(
                title: Text('Error'),
                content: Text('Data does not exist.'),
              );
            }

            var data = json
                .decode(snapshot.data!.body); // Assuming the response is JSON
            String title = data['title'] ?? "No Title";
            String description = data['description'] ?? "No Description";
            int views = data['views'] ?? 1000;
            DateTime uploadedAt = DateTime.parse(data['createdAt']);

            return AlertDialog(
              title: const Text('Choose an Option'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Title: $title'),
                  Text('Description: $description'),
                  Text('Views: $views'),
                  Text('Uploaded At: ${uploadedAt.toString()}'),
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
                    foregroundColor: Colors
                        .red, // Change the text color to red for delete option
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
