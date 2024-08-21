import 'dart:developer';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/reels/screens/feed_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../../providers/reelProvider.dart';

Future<List<Video>> getVideoList(QuerySnapshot snapshot) async {
  List<Video> videoList = [];

  for (QueryDocumentSnapshot docu in snapshot.docs) {
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

Future<List<QueryDocumentSnapshot>> fetchLoops() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('loops').get();
  return querySnapshot.docs;
}

Future<List<Video>> getVideoListFromDocs(
    List<QueryDocumentSnapshot> docs) async {
  // Implement your logic to convert documents to a list of videos
  // For example:
  return docs
      .map((doc) => Video(
          id: doc['id'] as String,
          category: '',
          creatorName: '',
          maxVideoRes: '',
          uploadedBy: doc['uploadedBy'] as String,
          videoUrl: doc['videoUrl'] as String,
          title: doc['title'] as String,
          description: doc['description'] as String,
          thumbnail: doc['thumbnail'] as String,
          likes: doc['likes'] as List,
          views: doc['views'] as int))
      .toList();
}

final videoStreamProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>(
  (ref) {
    return FirebaseFirestore.instance.collection('loops').snapshots();
  },
);
final videoListProvider = StateProvider<List<Video>>((ref) => []);

class ReelsScreentest extends ConsumerStatefulWidget {
  const ReelsScreentest({super.key});

  @override
  ConsumerState<ReelsScreentest> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreentest>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  List<bool> isControllerDisposed = [];
  List<String> videoUrls = [];
  List<String> thubnailUrls = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // Add the observer
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: fetchLoops(),
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.requireData;

        videoUrls = docs.map((doc) => doc['videoUrl'] as String).toList();
        thubnailUrls = docs.map((doc) => doc['thumbnail'] as String).toList();

        return FutureBuilder<List<Video>>(
          future: getVideoListFromDocs(docs),
          builder: (context, videoListSnapshot) {
            if (videoListSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (videoListSnapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            final videoList = videoListSnapshot.requireData;

            return PreloadPageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                return FeedItem(
                  index: index,
                  // controller: videoControllers[index],

                  video: videoList[index],
                );
              },
              onPageChanged: (int position) {
                currentIndex = position;
                ref.read(indexProvider.notifier).setCurrentIndex(position);
              },
              preloadPagesCount: 3,
              controller: PreloadPageController(),
            );
          },
        );
      },
    );
  }
}
