import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/controller/video_list_controller.dart';
import 'package:com.while.while_app/feature/profile/screens/creators_reels_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/update_thumbnail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:com.while.while_app/data/model/video_model.dart';
// Ensure this import is correct

class CreatorProfile extends ConsumerStatefulWidget {
  const CreatorProfile({Key? key, required this.user}) : super(key: key);
  final ChatUser user;

  @override
  ConsumerState<CreatorProfile> createState() => _CreatorProfileState();
}

class _CreatorProfileState extends ConsumerState<CreatorProfile> {
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
            .collection('loops')
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
              final List<Video> videoList = ref
                  .read(videoListControllerProvider.notifier)
                  .videoList(snapshot.data);

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
                            final String id =
                                snapshot.data!.docs[startIndex + index].id;
                            _showOptionsDialog(
                                context, id, ref, videoList[index]);
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

  void _showOptionsDialog(
      BuildContext context, String id, WidgetRef ref, Video video) {
    const String apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
    const apiUrl = 'https://sandbox.api.video';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a FutureBuilder to fetch data in the background
        return FutureBuilder(
          future: http.get(
            Uri.parse('$apiUrl/videos/$id'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              // Add other headers if needed
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
              String thumbnail = data['assets']['thumbnail'] ?? "No Title";

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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectThumbnailScreen(
                                    videoId: id,
                                    initialThumbnailUrl: thumbnail,
                                  )));
                      // Perform the action for Option 1
                    },
                    child: const Text('Update thumbnail'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => SelectThumbnailScreen()));
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
