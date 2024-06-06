import 'dart:developer';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/reels/screens/feed_item.dart';
import 'package:com.while.while_app/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoList {
  // Static method to get the list of video URLs
  static List<Video> getVideoList(QuerySnapshot snapshot) {
    List<Video> videoList = [];
    // print(snapshot.docs.first.id);
    for (QueryDocumentSnapshot docu in snapshot.docs) {
      // Create a Video object using the data and add it to the list
      Video video = Video(
          id: docu.id,
          category: '',
          creatorName: '',
          maxVideoRes: '',
          uploadedBy: docu.get('uploadedBy'),
          videoUrl: docu.get('videoUrl'),
          title: docu.get('title'),
          description: docu.get('description'),
          thumbnail: docu.get('thumbnail'),
          likes: docu.get('likes'),
          views: docu.get('views'));
      videoList.add(video);
    }
    return videoList;
  }
}

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
    Future.microtask(() => ref.read(loopsProvider.notifier).fetchLoops());
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
        _controller2 = VideoPlayerController.contentUri(
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
          VideoPlayerController.contentUri(Uri.parse(video[index + 1].videoUrl))
            ..initialize();
    });
    return FeedItem(video: video[index], index: index, controller: controller2);
  }

  @override
  Widget build(BuildContext context) {
    final loopsState = ref.watch(loopsProvider);
    var videoStream = ref.watch(videoStreamProvider);
    List<VideoPlayerController> videoControllers = [];
    return videoStream.when(
      data: (QuerySnapshot snapshot) {
        final List<Video> videoList = VideoList.getVideoList(snapshot);
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
            _controller0 = VideoPlayerController.contentUri(
                Uri.parse(videoList[0].videoUrl))
              ..initialize();
            log("length of loops ${loopsState.loops.length} index $index");

            if (loopsState.loops.length <= index + 2) {
              //ref.read(loopsProvider.notifier).state.isLoading = false;
              ref.read(loopsProvider.notifier).fetchLoops();
            }
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
