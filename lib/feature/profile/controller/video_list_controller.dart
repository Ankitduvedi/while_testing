import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/profile/repository/videos_lists.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoListControllerProvider =
    StateNotifierProvider<VideoListController, bool>((ref) {
  return VideoListController(
      videoListRepository: ref.read(videoListRepositoryProvider));
});

class VideoListController extends StateNotifier<bool> {
  final VideoListRepository _videoListRepository;

  VideoListController({required VideoListRepository videoListRepository})
      : _videoListRepository = videoListRepository,
        super(false);

  List<Video> videoList(snapshot) => _videoListRepository.getVideoList(snapshot);
}
