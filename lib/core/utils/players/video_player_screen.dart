// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

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
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
      autoPlay: false,
      looping: false,
      showControls: true,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.black,
      ),
      autoInitialize: false,
    );
  }

  @override
  void dispose() {
    // print('Dispose is being called');
    _chewieController.dispose();
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
      body: Chewie(controller: _chewieController),
    );
  }
}
