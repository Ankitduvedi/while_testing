import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen_widget.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import 'creator_feed_screen_widget.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key, required this.video});

  final Video video;

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends ConsumerState<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isPortrait = true;
  List<String> filteredQualityOptions = [];
  List<String> validQualityOptions = [];
  String libraryID = '243538';
  String CDNHostname = 'vz-f0994fc7-d98.b-cdn.net';
  String url = '';

  List<String> availableRes = [];
  String currentQuality =
      '240p'; // Initial quality, can be dynamic based on API or default
  @override
  void initState() {
    url = 'https://${CDNHostname}/${widget.video.id}/240p/video.m3u8';
    super.initState();
    _initializePlayer();
    increaseView();
    // initializePlayer();
    // checkQualityOptions();
    // filterQualityOptions();
    // Set the status bar color to black
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Status bar color
      statusBarIconBrightness: Brightness.light, // Status bar icons' color
    ));
  }

  void increaseView() {
    print("id: ${widget.video.id}");

    FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.video.category)
        .collection(widget.video.category)
        .doc(widget.video.id)
        .update({
      'views': FieldValue.increment(1),
    });
  }

  void _onQualitySelected(String quality) async {
    await _chewieController?.pause();
    await _videoPlayerController.pause();
    _initializeVideoPlayer(quality);
    Navigator.pop(context);
  }

  void _initializeVideoPlayer(String quality) {
    List<String> parts = widget.video.videoUrl.split('/play');
    String baseVideoUrl = parts[0];
    final videoUrl = '${baseVideoUrl}/play_$quality.mp4';
    setState(() {
      _videoPlayerController =
          VideoPlayerController.network(widget.video.videoUrl)
            ..initialize().then((_) {
              setState(() {});
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController,
                autoPlay: true,
                looping: true,
              );
            });
    });
  }

  Future<void> _initializePlayer() async {
    availableRes = await getResolution(widget.video.id, libraryID);

    _videoPlayerController = VideoPlayerController.network(
        'https://$CDNHostname/${widget.video.id}/${availableRes[0]}/video.m3u8');

    await _videoPlayerController.initialize();

    _createQualityOptions();

    setState(() {});
  }

  Future<List<String>> getResolution(String videoId, String libraryId) async {
    print("videoId: $videoId, libraryId: $libraryId ${widget.video.videoUrl}");
    var url = Uri.parse(
        'https://video.bunnycdn.com/library/$libraryId/videos/$videoId');

    var headers = {
      'AccessKey': '6973830f-6890-472d-b8e3b813c493-5c4d-4c50',
      'accept': 'application/json',
    };

    var response = await http.get(url, headers: headers);
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var availableResolutions =
          jsonResponse['availableResolutions'].split(',');

      return availableResolutions;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void> initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.video.videoUrl);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      showControls: true,
      showOptions: true,
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    _chewieController!.addListener(() {
      setState(() {});
      if (_chewieController!.isFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
        });
        setState(() {
          isPortrait = false;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        });
        setState(() {
          isPortrait = true;
        });
      }
    });

    setState(() {});
  }

  bool _isResolutionLessThanOrEqual(String quality, String maxRes) {
    int qualityValue = int.parse(quality.replaceAll('p', ''));
    int maxResValue = int.parse(maxRes.replaceAll('p', ''));
    return qualityValue <= maxResValue;
  }

  @override
  Widget build(BuildContext context) {
    final notifService = ref.read(notifControllerProvider.notifier);
    final ChatUser me = ref.read(userProvider)!;
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
                      child: _chewieController != null &&
                              _chewieController!
                                  .videoPlayerController.value.isInitialized
                          ? Stack(
                              children: [
                                Chewie(controller: _chewieController!),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
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
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 39, 39, 39)),
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
                            return const CircularProgressIndicator();
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
                                            child: CircularProgressIndicator()),
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
            children: [
              Chewie(controller: _chewieController!),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: () {
                    _showQualityOptions(context);
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
  }

  void _createQualityOptions() {
    // Sort available resolutions in ascending order
    availableRes.sort((a, b) {
      int resolutionA = int.parse(a.replaceAll('p', ''));
      int resolutionB = int.parse(b.replaceAll('p', ''));
      return resolutionA.compareTo(resolutionB);
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () => _showQualityOptions(context),
            iconData: Icons.settings,
            title: 'Quality',
          ),
        ];
      },
    );
  }

  void _showQualityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text('Quality of Current Video'),
              subtitle: Text(currentQuality),
            ),
            Divider(),
            ...availableRes.map((resolution) {
              String resolutionUrl =
                  'https://$CDNHostname/${widget.video.id}/$resolution/video.m3u8';
              return ListTile(
                title: Text('$resolution Quality'),
                onTap: () {
                  Navigator.pop(context);
                  _changeQuality(resolutionUrl, resolution);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _changeQuality(String url, String resolution) async {
    final currentPosition = _videoPlayerController.value.position;

    setState(() {
      currentQuality = resolution;
    });

    _videoPlayerController.pause();
    _videoPlayerController = VideoPlayerController.network(url);
    await _videoPlayerController.initialize();
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () => _showQualityOptions(context),
            iconData: Icons.settings,
            title: 'Quality',
          ),
        ];
      },
    );

    _videoPlayerController.seekTo(currentPosition);
    _videoPlayerController.play();

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
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
