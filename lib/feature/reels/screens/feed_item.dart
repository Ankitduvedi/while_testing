import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:com.while.while_app/data/model/video_model.dart';

class FeedItem extends StatefulWidget {
  const FeedItem(
      {super.key,
      required this.video,
      required this.index,
      required this.controller});
  final Video video;
  final int index;
  final VideoPlayerController controller;
  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  User? user = FirebaseAuth.instance.currentUser;
  late VideoPlayerController _controller;
  bool likeTapped = false;

  @override
  void initState() {
    likeTapped = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller = widget.controller;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(children: [
        VideoPlayer(_controller),
        Column(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.video.title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            widget.video.description,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 90,
            ),
          ],
        ),
      ]),
    );
  }
}
