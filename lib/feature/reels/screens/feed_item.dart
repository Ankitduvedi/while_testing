import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/model/video_model.dart';
import '../../../providers/reelProvider.dart';

class FeedItem extends ConsumerStatefulWidget {
  final int index;
  final Video video;

  FeedItem({
    Key? key,
    required this.video,
    required this.index,
  }) : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends ConsumerState<FeedItem>
    with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  bool _likeTapped = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isViewed = false;
  late BetterPlayerController betterPlayerController;
  late String CreatorProfilePic;
  late String CreatorName;

  @override
  void initState() {
    checkLike();
    fetchUserDetails(widget.video.uploadedBy);
    print("upload by: ${widget.video.uploadedBy}");
    // widget.controller.addListener(_videoListener);
    WidgetsBinding.instance.addObserver(this); // Add the observer
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
            aspectRatio: 9 / 16,
            autoDispose: false,
            autoDetectFullscreenAspectRatio: false,
            fullScreenByDefault: false,
            fullScreenAspectRatio: 16 / 9,
            //AR dual time but it's okay.
            controlsConfiguration: BetterPlayerControlsConfiguration(
                enablePip: false,
                enableQualities: true,
                enableFullscreen: false,
                enableSubtitles: false,
                loadingColor: Colors.deepOrange,
                progressBarBufferedColor: Colors.red,
                showControlsOnInitialize: false,
                //very useful
                progressBarHandleColor: Colors.blue,
                progressBarBackgroundColor: Colors.white));
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.videoUrl.replaceAll("/240p/video.m3u8", "/playlist.m3u8"),
      videoFormat: BetterPlayerVideoFormat.hls, //don't forget it if not hsl
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 5000,
        bufferForPlaybackMs: 3000,
        bufferForPlaybackAfterRebufferMs: 3000,
      ),
      // cacheConfiguration is very useful
      cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 10 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
          preCacheSize: 3 * 1024 * 1024),
    );

    betterPlayerController = BetterPlayerController(betterPlayerConfiguration,
        betterPlayerDataSource: dataSource);
    super.initState();
  }

  Future<void> fetchUserDetails(String userId) async {
    log('fetchUserDetails: $userId');
    try {
      // Reference to the specific document in the users collection
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Return the user data as a Map
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          CreatorProfilePic = data['image'];
          CreatorName = data['name'];
          log('CreatorProfilePic: $CreatorProfilePic');
          log('CreatorName: $CreatorName');
        });
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching user details:$userId $e');
      return null;
    }
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    // widget.controller.removeListener(_videoListener);
    // widget.controller.dispose();
    super.dispose();
  }

  void checkLike() {
    log("Checking like ${widget.video.likes} ${user!.uid}");
    if (widget.video.likes.contains(user!.uid)) {
      setState(() {
        _likeTapped = true;
      });
    } else {
      setState(() {
        _likeTapped = false;
      });
    }
  }

  Future<void> incrementViewCount(String videoId) async {
    try {
      DocumentReference videoDoc = _firestore.collection('loops').doc(videoId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(videoDoc);
        if (!snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          int currentViews = data['views'] ?? 0;
          transaction.update(videoDoc, {'views': currentViews + 1});
        }
      });
      print("View count incremented successfully");
    } catch (e) {
      print("Failed to increment view count: $e");
    }
  }

  Future<void> updateUserReaction(
      String videoId, String userId, bool isLike) async {
    try {
      DocumentReference videoDoc = _firestore.collection('loops').doc(videoId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(videoDoc);
        if (!snapshot.exists) {
          throw Exception("Video does not exist!");
        }
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> likes = data['likes'] ?? [];
        if (isLike) {
          if (!likes.contains(userId)) {
            likes.add(userId);
          }
        } else {
          likes.remove(userId);
        }
        transaction.update(videoDoc, {'likes': likes});
      });
      print("User reaction updated successfully");
    } catch (e) {
      print("Failed to update user reaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(indexProvider);
    if (currentIndex == widget.index) {
      incrementViewCount(widget.video.id);
      betterPlayerController.play();
    } else {
      betterPlayerController.pause();
    }
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          bool? isPlaying = betterPlayerController.isPlaying();
          if (isPlaying!) {
            betterPlayerController.pause();
          } else {
            ref.read(indexProvider.notifier).setCurrentIndex(widget.index);
            betterPlayerController.play();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              BetterPlayer(
                controller: betterPlayerController,
              ),
              Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  child: CommentWithPublisher(
                      creatorName: CreatorName,
                      profilePic: CreatorProfilePic,
                      video: widget.video)),
              buildPosLikeComment(widget.video.likes.length,
                  widget.video.views + currentIndex == widget.index ? 1 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Positioned buildPosLikeComment(int likeCount, int views) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25,
      right: 10,
      width: 50,
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_likeTapped) {
                    updateUserReaction(widget.video.id, user!.uid, false);
                    _likeTapped = false;
                  } else {
                    updateUserReaction(widget.video.id, user!.uid, true);
                    _likeTapped = true;
                  }
                });
              },
              child: iconDetail(
                _likeTapped ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                '$likeCount',
                _likeTapped ? Colors.red : Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            iconDetail(Icons.remove_red_eye, '$views', null),
            const SizedBox(height: 30),
            iconDetail(CupertinoIcons.arrow_turn_up_right, '', null),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Container circleImage(String networkImage, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xff7c94b6),
      image: DecorationImage(
        image: NetworkImage(networkImage == ""
            ? "https://cdn-icons-png.flaticon.com/512/2815/2815428.png"
            : networkImage),
        fit: BoxFit.cover,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
      gradient: const LinearGradient(colors: [
        Colors.red,
        Colors.pink,
      ]),
      border: Border.all(
        color: Colors.red,
        width: 2.0,
      ),
    ),
  );
}

Container rectImage(String networkImage, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xff7c94b6),
      image: DecorationImage(
        image: NetworkImage(networkImage),
        fit: BoxFit.cover,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      gradient: const LinearGradient(colors: [
        Colors.red,
        Colors.pink,
      ]),
      border: Border.all(
        color: Colors.red,
        width: 2.0,
      ),
    ),
  );
}

Column iconDetail(IconData icon, String number, Color? color) {
  return Column(
    children: [
      Icon(
        icon,
        size: 33,
        color: color != null ? color : Colors.white,
      ),
      Text(
        '$number',
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
      )
    ],
  );
}

class CommentWithPublisher extends StatefulWidget {
  final Video video;
  final String profilePic;
  final String creatorName;

  CommentWithPublisher({
    Key? key,
    required this.video,
    required this.profilePic,
    required this.creatorName,
  }) : super(key: key);

  @override
  _CommentWithPublisherState createState() => _CommentWithPublisherState();
}

class _CommentWithPublisherState extends State<CommentWithPublisher> {
  @override
  Widget build(BuildContext context) => Container(
        height: 250,
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      circleImage('${widget.profilePic}', 30),
                      const SizedBox(width: 8.0),
                      Text('${widget.creatorName}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 8.0),
                      // Text(
                      //   'Follow',
                      //   style: textStyle,
                      // )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    children: [
                      Text(
                        '${widget.video.title}',
                        style: textStyle,
                      ),
                      Text(
                        '${widget.video.description}',
                        overflow: TextOverflow.ellipsis,
                        style: greyText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            )
          ],
        ),
      );

  TextStyle textStyle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15.0);
  TextStyle greyText = const TextStyle(
    color: Colors.grey,
  );
}
