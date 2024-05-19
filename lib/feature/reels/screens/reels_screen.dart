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

  Widget text(VideoPlayerController controller1, int index, List<Video> video) {
    controller1.play().whenComplete(
      () {
        _controller2 = VideoPlayerController.networkUrl(
          Uri.parse(
              "https://iframe.mediadelivery.net/play/239543/e080998b-3823-40ad-9a69-da33782c4b26/play_360p.mp4"),
          httpHeaders: {
            "AccessKey": 'dcd568cf-99ae-4d4d-9d5df4920f3f-7e3b-478d',
            "Content-Type": "application/json"
          },
        )..initialize();
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
