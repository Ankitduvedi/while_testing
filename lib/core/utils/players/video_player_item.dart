import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';


class VideoPlayerItem extends StatefulWidget {
  const VideoPlayerItem({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late BetterPlayerController betterPlayerController;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
   betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(color: Colors.black),
      child: BetterPlayer(controller: betterPlayerController),
    );
  }
}
