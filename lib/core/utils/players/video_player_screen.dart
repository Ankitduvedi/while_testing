// ignore_for_file: library_private_types_in_public_api

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            autoDispose: true,
            autoDetectFullscreenAspectRatio: true,
            fullScreenByDefault: true,
            fullScreenAspectRatio: 16 / 9,
            //AR dual time but it's okay.
            controlsConfiguration: BetterPlayerControlsConfiguration(
                enablePip: false,
                enableFullscreen: true,
                enableSubtitles: false,
                loadingColor: Colors.deepOrange,
                progressBarBufferedColor: Colors.red,
                //very useful
                progressBarHandleColor: Colors.blue,
                progressBarBackgroundColor: Colors.white));
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      videoFormat: BetterPlayerVideoFormat.hls, //don't forget it if not hsl
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 131072,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
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
  }

  @override
  void dispose() {
    // print('Dispose is being called');
    betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.videoTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                dispose();
                context.pop();
              },
              icon: const Icon(Icons.arrow_back))
        ],
      ),
      body: BetterPlayer(controller: betterPlayerController),
    );
  }
}
