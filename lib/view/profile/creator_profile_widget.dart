import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:while_app/controller/videos_lists.dart';
import 'package:while_app/data/model/video_model.dart';
import 'package:while_app/main.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/view/profile/creators_reels_screen.dart';

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
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreatorReelsScreen(
                                        video: videoList[startIndex + index],
                                        index: 0,
                                      ))),
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
}
