import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/repository/videos_lists.dart';
import 'package:com.while.while_app/feature/profile/screens/creators_reels_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:com.while.while_app/data/model/video_model.dart';
// Ensure this import is correct

class CreatorProfileVideo extends ConsumerStatefulWidget {
  const CreatorProfileVideo({Key? key, required this.user}) : super(key: key);
  final ChatUser user;

  @override
  ConsumerState<CreatorProfileVideo> createState() => _CreatorProfileState();
}

class _CreatorProfileState extends ConsumerState<CreatorProfileVideo> {
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Size mq;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(widget.user.id)
              .collection('videos')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final List<Video> videoList =
                VideoList.getVideoList(snapshot.data!);

            return ListView.builder(
              scrollDirection:
                  Axis.vertical, // Make the list scroll horizontally
              itemCount: videoList.length, // Calculate the number of rows
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                      onLongPress: () {
                        final String id = snapshot.data!.docs[index].id;
                        _showOptionsDialog(context, id, ref);
                      },
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreatorReelsScreen(
                                  video: videoList[index],
                                  index: 0,
                                )));
                      },
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              // borderRadius: BorderRadius.circular(mq.height * .13),
                              child: CachedNetworkImage(
                                height: mq.width / 3,
                                fit: BoxFit.cover,
                                width: mq.width / 2,
                                imageUrl: videoList[index].thumbnail,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  videoList[index].title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  videoList[index].description,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 78, 78, 78)),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                );
              },
            );
          },
        ));
  }

  void _showOptionsDialog(BuildContext context, String id, WidgetRef ref) {
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
                ref.read(apisProvider).deleteReel(id);
                // APIs.deleteReel(id);
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
                      ref.read(apisProvider).deleteReel(id);
                      // APIs.deleteReel(id);
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
