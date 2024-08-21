import 'dart:convert';
import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen_widget.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'creator_feed_screen_widget.dart';

class VideoScreen extends ConsumerStatefulWidget {
  VideoScreen({super.key, required this.video});

  Video video;

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends ConsumerState<VideoScreen> {
  late BetterPlayerController betterPlayerController;
  bool isPortrait = true;
  List<String> filteredQualityOptions = [];
  List<String> validQualityOptions = [];
  String libraryID = '243538';
  String CDNHostname = 'vz-f0994fc7-d98.b-cdn.net';
  String url = '';
  bool isLiked = true;

  List<String> availableRes = [];
  String currentQuality =
      '240p'; // Initial quality, can be dynamic based on API or default
  @override
  void initState() {
    checkLike(ref.read(userDataProvider).userData!.id);
    print("video url: ${widget.video.videoUrl}");
    print(
        "new url is ${widget.video.videoUrl.replaceAll("/play_360p.mp4", "/playlist.m3u8")} ");
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            autoDispose: true,
            autoDetectFullscreenAspectRatio: false,
            fullScreenByDefault: false,
            fullScreenAspectRatio: 16 / 9,
            //AR dual time but it's okay.
            controlsConfiguration: BetterPlayerControlsConfiguration(
                enablePip: false,
                enableFullscreen: true,
                enableSubtitles: false,
                showControlsOnInitialize: false,
                loadingColor: Colors.yellowAccent,
                progressBarBufferedColor: Colors.red,
                //very useful
                progressBarHandleColor: Colors.blue,
                progressBarBackgroundColor: Colors.white));
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.videoUrl.replaceAll("/play_360p.mp4", "/playlist.m3u8"),
      videoFormat: BetterPlayerVideoFormat.hls, //don't forget it if not hsl
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 5000,
        bufferForPlaybackMs: 500,
        bufferForPlaybackAfterRebufferMs: 500,
      ),

      // cacheConfiguration is very useful
      cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 10 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
          preCacheSize: 3 * 1024 * 1024),
    );

    betterPlayerController = BetterPlayerController(betterPlayerConfiguration,
        betterPlayerDataSource: dataSource);
    betterPlayerController.play();
    if (betterPlayerController.isVideoInitialized() == true) {
      setState(() {});
      betterPlayerController.play();
    }
    _initializePlayer();
    increaseView();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Status bar color
      statusBarIconBrightness: Brightness.light, // Status bar icons' color
    ));
  }

  void checkLike(String userId) async {
    DocumentReference videoDoc = FirebaseFirestore.instance
        .collection('videos/${widget.video.category}/${widget.video.category}')
        .doc(widget.video.id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(videoDoc);
      if (!snapshot.exists) {
        throw Exception("Video does not exist!");
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      List<dynamic> likes = data['likes'] ?? [];
      log("Checking like ${likes} ${userId}");
      widget.video.likes = likes;
      if (likes.contains(userId)) {
        setState(() {
          isLiked = true;
        });
      } else {
        setState(() {
          isLiked = false;
        });
      }
    });
  }

  void increaseView() {
    log("id: ${widget.video.id}");

    FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.video.category)
        .collection(widget.video.category)
        .doc(widget.video.id)
        .update({
      'views': FieldValue.increment(1),
    });
  }

  Future<void> updateUserReaction(
      String videoId, String userId, bool isLike) async {
    try {
      DocumentReference videoDoc = FirebaseFirestore.instance
          .collection(
              'videos/${widget.video.category}/${widget.video.category}')
          .doc(videoId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(videoDoc);
        if (!snapshot.exists) {
          throw Exception("Video does not exist!");
        }
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<dynamic> likes = data['likes'] ?? [];
        print("likes: $likes userId $userId");
        if (isLike) {
          if (!likes.contains(userId)) {
            print("adding like");
            likes.add(userId);
          }
        } else {
          likes.remove(userId);
        }
        print("afterlikes: $likes userId $userId");
        transaction.update(videoDoc, {'likes': likes});
      });
      print("User reaction updated successfully2");
    } catch (e) {
      print("Failed to update user reaction1: $e");
    }
  }

  Future<void> _initializePlayer() async {}

  Future<List<String>> getResolution(String videoId, String libraryId) async {
    log("videoId: $videoId, libraryId: $libraryId ${widget.video.videoUrl}");
    var url = Uri.parse(
        'https://video.bunnycdn.com/library/$libraryId/videos/$videoId');

    var headers = {
      'AccessKey': '6973830f-6890-472d-b8e3b813c493-5c4d-4c50',
      'accept': 'application/json',
    };

    var response = await http.get(url, headers: headers);
    log("response: ${response.body}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var availableResolutions =
          jsonResponse['availableResolutions'].split(',');

      return availableResolutions;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  bool _isResolutionLessThanOrEqual(String quality, String maxRes) {
    int qualityValue = int.parse(quality.replaceAll('p', ''));
    int maxResValue = int.parse(maxRes.replaceAll('p', ''));
    return qualityValue <= maxResValue;
  }

  @override
  Widget build(BuildContext context) {
    final notifService = ref.read(notifControllerProvider.notifier);
    final ChatUser me = ref.read(userDataProvider).userData!;
    final followingUsersList = ref.watch(followingUsersProvider('id'));

    return isPortrait
        ? Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        color: Colors.black,
                        height: 300,
                        child: Stack(
                          children: [
                            BetterPlayer(
                              controller: betterPlayerController,
                            ),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 7, 0),
                      child: Text(
                        widget.video.title,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 7, 0),
                      child: Text(
                        widget.video.description,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 7, 0),
                      child: Text(
                        widget.video.views.toString() + ' views',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 7, 0),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  updateUserReaction(
                                      widget.video.id,
                                      ref.read(userDataProvider).userData!.id,
                                      isLiked);
                                  isLiked = !isLiked;
                                });
                              },
                              icon: Icon(isLiked
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_off_alt_outlined)),
                          SizedBox(
                            width: 30,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              CupertinoIcons.arrow_turn_up_right,
                            ),
                          )
                        ],
                      ),
                    ),
                    StreamBuilder(
                      stream: ref
                          .read(apisProvider)
                          .getUserInfo(widget.video.uploadedBy),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator(
                              color: Colors.green,
                            );
                          default:
                            if (snapshot.data != null) {
                              ChatUser user = snapshot.data!;
                              return ListTile(
                                leading: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ProfileDialog(user: user),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(user.image),
                                  ),
                                ),
                                title: Text(user.name,
                                    style: GoogleFonts.ptSans()),
                                subtitle: Text(user.email,
                                    style: GoogleFonts.ptSans()),
                                trailing: user.id == me.id
                                    ? const Text('')
                                    : followingUsersList.when(
                                        data: (followingUsers) {
                                          return followingUsers
                                                  .contains(user.id)
                                              ? ElevatedButton(
                                                  onPressed: () async {
                                                    final didUnfollow =
                                                        await ref
                                                            .read(apisProvider)
                                                            .unfollow(user.id)
                                                            .then((value) {
                                                      if (value) {
                                                        Dialogs.showSnackbar(
                                                            context,
                                                            'Unfollowed');
                                                      }
                                                    });

                                                    if (didUnfollow) {
                                                      notifService.addNotification(
                                                          '${user.name} stopped following you',
                                                          user.id);
                                                      log("now unfollowing");
                                                    } else {
                                                      log("failed to unfollow");
                                                    }
                                                  },
                                                  child: Text('Unfollow',
                                                      style:
                                                          GoogleFonts.ptSans()),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () async {
                                                    final didFollow =
                                                        await ref.read(
                                                                followUserProvider)(
                                                            user.id);

                                                    if (didFollow) {
                                                      notifService.addNotification(
                                                          '${user.name} started following you',
                                                          user.id);
                                                      log("now following");
                                                    } else {
                                                      log("failed to follow");
                                                    }
                                                  },
                                                  child: Text('Follow',
                                                      style:
                                                          GoogleFonts.ptSans()),
                                                );
                                        },
                                        loading: () => const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.cyan,
                                        )),
                                        error: (e, _) =>
                                            Center(child: Text('Error: $e')),
                                      ),
                              );
                            } else {
                              return const Text('No data to show');
                            }
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 17, 10),
                      child: Text(
                        'Similar videos',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    FeedScreenWidget(category: widget.video.category),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 17, 10),
                      child: Text(
                        'More videos from the creator',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    CreatorFeedScreenWidget(id: widget.video.uploadedBy),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          )
        : Stack(
            children: [],
          );
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}

class QualityOptions extends StatelessWidget {
  final List<String> filteredQualityOptions;
  final Function(String) onQualitySelected;

  const QualityOptions({
    required this.filteredQualityOptions,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Video Quality',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: filteredQualityOptions.map((quality) {
                return ListTile(
                  title: Text(quality),
                  onTap: () => onQualitySelected(quality),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> allQualityOptions = [
  '720p',
  '480p',
  '360p',
  '240p',
];
