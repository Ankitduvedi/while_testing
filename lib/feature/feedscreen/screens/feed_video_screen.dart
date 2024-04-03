import 'dart:developer';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen_widget.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:com.while.while_app/feature/social/controller/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
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

  @override
  void initState() {
    super.initState();
    initializePlayer();
    // Set the status bar color to black
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Status bar color
      statusBarIconBrightness: Brightness.light, // Status bar icons' color
    ));
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    _chewieController!.addListener(() {
      if (_chewieController!.isFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        });
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notifService = ref.read(notifControllerProvider.notifier);
    final ChatUser me = ref.read(userProvider)!;
    final followingUsersList = ref.watch(followingUsersProvider('userId'));

    return Scaffold(
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
                    ? Chewie(
                        controller: _chewieController!,
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
                      fontSize: 15, color: Color.fromARGB(255, 39, 39, 39)),
                ),
              ),
              StreamBuilder(
                stream:
                    ref.read(apisProvider).getUserInfo(widget.video.uploadedBy),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }
                  // Check for connection state before attempting to access the data
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      // Show a loading indicator while waiting for the data
                      return const CircularProgressIndicator();
                    default:
                      // Ensure data is not null before accessing it
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
                          title: Text(
                            user.name,
                            style: GoogleFonts.ptSans(),
                          ),
                          subtitle:
                              Text(user.email, style: GoogleFonts.ptSans()),
                          trailing: user.id == me.id
                              ? const Text('')
                              : followingUsersList.when(
                                  data: (followinguserslist) {
                                    return followinguserslist.contains(user.id)
                                        ? ElevatedButton(
                                            onPressed: () async {
                                              final didunFollow = await ref
                                                  .read(apisProvider)
                                                  .unfollow(user.id)
                                                  .then((value) {
                                                if (value) {
                                                  Dialogs.showSnackbar(
                                                      context, 'Unfollowed');
                                                }
                                              });

                                              if (didunFollow) {
                                                notifService.addNotification(
                                                    '${user.name} started following you',
                                                    user.id);
                                                log("now following");
                                              } else {
                                                log("failed to follow");
                                              }
                                            },
                                            child: Text('Unfollow',
                                                style: GoogleFonts.ptSans()),
                                          )
                                        : ElevatedButton(
                                            onPressed: () async {
                                              final didFollow = await ref.read(
                                                  followUserProvider)(user.id);

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
                                                style: GoogleFonts.ptSans()),
                                          );
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, _) =>
                                      Center(child: Text('Error: $e')),
                                ),
                        );
                      } else {
                        // Handle the case where data is null
                        return const Text(
                          'No data to show',
                        );
                      }
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 17, 10),
                child: Text(
                  'Similar videos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              FeedScreenWidget(category: widget.video.category),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 17, 10),
                child: Text(
                  'More videos from the creator',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              CreatorFeedScreenWidget(
                id: widget.video.uploadedBy,
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
