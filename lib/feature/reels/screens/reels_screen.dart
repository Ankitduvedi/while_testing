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
  bool hasvideo = false;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  late VideoPlayerController _controller0;
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  final int _limit = 3;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  List<Video> videoList = [];

  @override
  @override
  void initState() {
    // TODO: implement initState
    fetchNextPage();
    super.initState();
  }

  void dispose() {
    _pageController.dispose();
    _controller0.dispose();
    _controller1.dispose();
    _controller2.dispose();

    super.dispose();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;

    Query query = FirebaseFirestore.instance.collection('loops').limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot querySnapshot = await query.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    videoList.addAll(ref
        .read(videoListControllerProvider.notifier)
        .videoList(querySnapshot));
    print("list len is ${videoList.length}");
    for (int i = 0; i < videoList.length; i++) {
      print("video url is ${videoList[i].videoUrl}");
    }
    setState(() {
      hasvideo = true;
    });

    if (querySnapshot.docs.length < _limit) {
      _hasMore = false;
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    _isLoading = false;
  }

  Widget text(VideoPlayerController controller1, int index, List<Video> video,
      String videoUrl) {
    controller1.play().whenComplete(
      () {
        _controller2 = VideoPlayerController.network(video[index + 1].videoUrl)
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
      _controller1 = VideoPlayerController.network(video[index + 1].videoUrl)
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
    return !hasvideo
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videoList.length,

              // onPageChanged: (int newIndex) {
              //   videoControllers[_currentPage].dispose();
              //   setState(() {
              //     _currentPage = newIndex;
              //   });
              // },
              itemBuilder: (context, index) {
                // return CircularProgressIndicator();
                if (index == videoList.length - 3) {
                  fetchNextPage();
                }
                if (index == videoList.length - 1) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Center(child: CircularProgressIndicator()));
                }

                List<String> parts = videoList[0].videoUrl.split('/play');
                // The part before '/play' will be the first element in the list
                String videoUrl = parts[0];
                _controller0 =
                    VideoPlayerController.network(videoList[0].videoUrl)
                      ..initialize();
                return FeedItem(
                  video: videoList[index],
                  index: index,
                  controller: _controller0,
                  baseVideoUrl: videoUrl,
                );

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
            ));

    // FutureBuilder<QuerySnapshot>(
    //   future: streamData,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }
    //
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text('Error: ${snapshot.error}'),
    //       );
    //     }
    //     final videoList = ref
    //         .read(videoListControllerProvider.notifier)
    //         .videoList(snapshot.data);
    //
    //     videoList.shuffle();
    //     return PageView.builder(
    //       controller: _pageController,
    //       scrollDirection: Axis.vertical,
    //       itemCount: videoList.length,
    //       onPageChanged: (int newIndex) {
    //         videoControllers[_currentPage].dispose();
    //         setState(() {
    //           _currentPage = newIndex;
    //         });
    //       },
    //       itemBuilder: (context, index) {
    //         if (index == videoList.length - 3) {}
    //         List<String> parts = videoList[0].videoUrl.split('/play');
    //         // The part before '/play' will be the first element in the list
    //         String videoUrl = parts[0];
    //         _controller0 = VideoPlayerController.networkUrl(
    //             Uri.parse(videoList[0].videoUrl))
    //           ..initialize();
    //         if (_lastPage > index) {
    //           _lastPage--;
    //           return text(_controller0, index, videoList, videoUrl);
    //         } else {
    //           _lastPage++;
    //           return (index % 2 == 0)
    //               ? text(index == 0 ? _controller0 : _controller1, index,
    //                   videoList, videoUrl)
    //               : text2(_controller2, index, videoList, videoUrl);
    //         }
    //       },
    //     );
    //   });
  }
}
