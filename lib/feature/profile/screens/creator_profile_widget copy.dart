import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/controller/video_list_controller.dart';
import 'package:com.while.while_app/feature/profile/screens/creators_reels_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/update_thumbnail.dart';
import 'package:com.while.while_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.while.while_app/data/model/video_model.dart';

import '../../../providers/user_provider copy.dart';
// Ensure this import is correct

class CreatorProfileVideo extends ConsumerStatefulWidget {
  const CreatorProfileVideo({Key? key, required this.user}) : super(key: key);
  final ChatUser user;

  @override
  ConsumerState<CreatorProfileVideo> createState() => _CreatorProfileState();
}

class _CreatorProfileState extends ConsumerState<CreatorProfileVideo> {
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
            final List<Video> videoList = ref
                .read(videoListControllerProvider.notifier)
                .videoList(snapshot.data);

            return ListView.builder(
              scrollDirection:
                  Axis.vertical, // Make the list scroll horizontally
              itemCount: videoList.length, // Calculate the number of rows
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                      onLongPress: () {
                        _showOptionsDialog(context, ref, videoList[index]);
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
                              borderRadius:
                                  BorderRadius.circular(mq.height * .01),
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
                                SizedBox(
                                  width: mq.width / 3,
                                  child: Text(
                                    videoList[index].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: mq.width / 3,
                                  child: Text(
                                    videoList[index].description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: const Color.fromARGB(
                                            255, 87, 87, 87)),
                                  ),
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

  void _showOptionsDialog(BuildContext context, WidgetRef ref, Video video) {
    // final Uri uri =
    //     Uri.parse('https://video.bunnycdn.com/library/243538/videos/$id');
    // const String apiKey = '6973830f-6890-472d-b8e3b813c493-5c4d-4c50';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // Use a FutureBuilder to fetch data in the background
          return AlertDialog(
            title: const Hero(
              tag: 'dialog-title', // Use a unique tag for the Hero widget
              child: Material(
                type: MaterialType.transparency,
                child: Text('Choose an Option',
                    style: TextStyle(fontSize: 16.0)), // Set a fixed text size
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'dialog-content',
                  // Use a unique tag for the Hero widget
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Title: ${video.title}',
                            style: const TextStyle(
                                fontSize: 14.0)), // Set a fixed text size
                        Text('Description: ${video.description}',
                            style: const TextStyle(
                                fontSize: 14.0)), // Set a fixed text size
                        Text('Views: ${video.views}',
                            style: const TextStyle(
                                fontSize: 14.0)), // Set a fixed text size
                        // Text('Uploaded At: ${video.}',
                        //     style: const TextStyle(
                        //         fontSize: 14.0)), // Set a fixed text size
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
                              category: video.category,
                              videoId: video.id,
                              initialThumbnailUrl: video.thumbnail)));
                  // Perform the action for Option 1
                },
                child: const Text('Set Thumbnail'),
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
                  var userId = ref.read(userDataProvider).userData?.id;
                  ref
                      .read(apisProvider)
                      .deleteVideo(video.id, video.category, userId!);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        });
  }
}
