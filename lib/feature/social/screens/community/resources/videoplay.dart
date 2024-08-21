import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPlay extends StatefulWidget {
  final String url;

  const VideoPlay({
    super.key,
    required this.url,
  });

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
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
      widget.url,
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
    betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: betterPlayerController.isVideoInitialized() == true
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BetterPlayer(controller: betterPlayerController),
                const SizedBox(height: 20),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
