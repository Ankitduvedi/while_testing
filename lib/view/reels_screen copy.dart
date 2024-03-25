import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:com.example.while_app/controller/feed_item.dart';
import 'package:com.example.while_app/controller/videos_lists.dart';
import 'package:com.example.while_app/data/model/video_model.dart';
import '../view_model/providers/data_provider.dart';

class ReelsScreentest extends ConsumerStatefulWidget {
  const ReelsScreentest({super.key});

  @override
  ConsumerState<ReelsScreentest> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreentest> {
  int _currentPage = 0;
  int _lastPage = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  late VideoPlayerController _controller0;
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    Future.microtask(() => ref.watch(loopsProvider.notifier).fetchLoops());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller0.dispose();
    _controller1.dispose();
    _controller2.dispose();

    super.dispose();
  }

  Widget text(VideoPlayerController controller1, int index, List<Video> video) {
    controller1.play().whenComplete(
      () {
        _controller2 = VideoPlayerController.networkUrl(
            Uri.parse(video[index + 1].videoUrl))
          ..initialize();
      },
    );
    return FeedItem(video: video[index], index: index, controller: controller1);
  }

  Widget text2(
      VideoPlayerController controller2, int index, List<Video> video) {
    controller2.play().then((value) {
      _controller1 =
          VideoPlayerController.networkUrl(Uri.parse(video[index + 1].videoUrl))
            ..initialize();
    });
    return FeedItem(video: video[index], index: index, controller: controller2);
  }
  //*********************************************************************************** */
  // replace the future builder with streamprovider or asyncalue with .when ()

  @override
  Widget build(BuildContext context) {
    final loopsState = ref.watch(loopsProvider);
    List<VideoPlayerController> videoControllers = [];
    final streamData = ref.watch(videoStreamProvider.future);
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: streamData,
        // stream: FirebaseFirestore.instance.collection('loops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final List<Video> videoList = VideoList.getVideoList(snapshot.data!);
          videoList.shuffle();
          log("length of loops ${loopsState.loops.length + (loopsState.isLoading ? 1 : 0)}");
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: loopsState.loops.length + (loopsState.isLoading ? 1 : 0),
            //itemCount: videoList.length,
            onPageChanged: (int newIndex) {
              videoControllers[_currentPage].dispose();
              setState(() {
                _currentPage = newIndex;
              });
            },
            itemBuilder: (context, index) {
              _controller0 = VideoPlayerController.networkUrl(
                  Uri.parse(videoList[0].videoUrl))
                ..initialize();
              if (_lastPage > index) {
                _lastPage--;
                return text(_controller0, index, videoList);
              } else {
                _lastPage++;
                return (index % 2 == 0)
                    ? text(index == 0 ? _controller0 : _controller1, index,
                        videoList)
                    : text2(_controller2, index, videoList);
              }
            },
          );
        });
  }
}
