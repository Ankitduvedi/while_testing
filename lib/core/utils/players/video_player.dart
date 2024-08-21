import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late BetterPlayerController betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            aspectRatio: 9 / 16,
            autoDispose: true,
            autoDetectFullscreenAspectRatio: false,
            fullScreenByDefault: false,

            //AR dual time but it's okay.
            controlsConfiguration: BetterPlayerControlsConfiguration(
                enableQualities: false,
                enablePlaybackSpeed: false,
                enableAudioTracks: false,
                enableOverflowMenu: false,
                showControlsOnInitialize: false,
                overflowMenuIconsColor: Colors.pink,
                overflowMenuCustomItems: [],
                enablePip: false,
                enableFullscreen: false,
                enableSubtitles: false,
                loadingColor: Colors.deepOrange,
                progressBarBufferedColor: Colors.red,
                //very useful
                progressBarHandleColor: Colors.blue,
                progressBarBackgroundColor: Colors.white));
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.memory, "",
        bytes: File(widget.videoPath).readAsBytesSync(), videoExtension: ".mp4"

        // cacheConfiguration is very useful
        );

    betterPlayerController = BetterPlayerController(betterPlayerConfiguration,
        betterPlayerDataSource: dataSource);
    setState(() {});
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: BetterPlayer(controller: betterPlayerController),
    )
        //     FutureBuilder(
        //   future: _initializeVideoPlayerFuture,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       return ;
        //     } else {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //   },
        // )
        );
  }
}
