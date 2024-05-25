import 'package:com.while.while_app/feature/profile/controller/video_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:com.while.while_app/feature/reels/screens/feed_item.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import '../../../providers/data_provider.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  int _currentPage = 0;
  int _lastPage = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  late VideoPlayerController _controller0;
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;

  @override
  void dispose() {
    _pageController.dispose();
    _controller0.dispose();
    _controller1.dispose();
    _controller2.dispose();

    super.dispose();
  }

  Widget text(VideoPlayerController controller1, int index, List<Video> video,
      String videoUrl) {
    controller1.play().whenComplete(
      () {
        _controller2 = VideoPlayerController.networkUrl(
            Uri.parse(video[index + 1].videoUrl))
          ..initialize();
      },
    );
    return FeedItem(
      video: video[index],
      index: index,
      controller: controller1,
      baseVideoUrl: videoUrl,
    );
  }

  Widget text2(VideoPlayerController controller2, int index, List<Video> video,
      String videoUrl) {
    controller2.play().then((value) {
      _controller1 =
          VideoPlayerController.networkUrl(Uri.parse(video[index + 1].videoUrl))
            ..initialize();
    });
    return FeedItem(
      video: video[index],
      index: index,
      controller: controller2,
      baseVideoUrl: videoUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<VideoPlayerController> videoControllers = [];
    final streamData = ref.read(videoStreamProvider.future);
    return FutureBuilder<QuerySnapshot>(
        future: streamData,
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
          final videoList = ref
              .read(videoListControllerProvider.notifier)
              .videoList(snapshot.data);

          videoList.shuffle();
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videoList.length,
            onPageChanged: (int newIndex) {
              videoControllers[_currentPage].dispose();
              setState(() {
                _currentPage = newIndex;
              });
            },
            itemBuilder: (context, index) {
              List<String> parts = videoList[0].videoUrl.split('/play');
              // The part before '/play' will be the first element in the list
              String videoUrl = parts[0];
              _controller0 = VideoPlayerController.networkUrl(
                  Uri.parse(videoList[0].videoUrl))
                ..initialize();
              if (_lastPage > index) {
                _lastPage--;
                return text(_controller0, index, videoList, videoUrl);
              } else {
                _lastPage++;
                return (index % 2 == 0)
                    ? text(index == 0 ? _controller0 : _controller1, index,
                        videoList, videoUrl)
                    : text2(_controller2, index, videoList, videoUrl);
              }
            },
          );
        });
  }
}
