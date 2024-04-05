import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoListRepositoryProvider = Provider<VideoListRepository>((ref) {
  return VideoListRepository();
});

class VideoListRepository {
  List<Video> getVideoList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => Video(
              category: doc.get('category') ?? '',
              id: doc.id,
              uploadedBy: doc.get('uploadedBy') ?? '',
              creatorName: doc.get('creatorName') ?? '',
              videoUrl: doc.get('videoUrl') ?? '',
              title: doc.get('title') ?? '',
              description: doc.get('description') ?? '',
              thumbnail: doc.get('thumbnail') ?? '',
              likes: doc.get('likes') ?? 0,
              views: doc.get('views') ?? 0,
            ))
        .toList();
  }
}
