import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allVideosProvider =
    StreamProvider.family<List<Video>, String>((ref, collectionPath) {
  //log('Fetching videos from $collectionPath');
  return FirebaseFirestore.instance
      .collection('videos')
      .doc(collectionPath)
      .collection(collectionPath)
      .snapshots()
      .map((snapshot) {
    // log('videoList.length.toString()///');

    var videoList =
        snapshot.docs.map((doc) => Video.fromMap(doc.data())).toList();
    // log('videoList.length.toString()');

    // log(videoList.length.toString());
    return videoList;
  });
});

final videosCategory = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('videosCategories')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

//
// State for categories pagination
class CategoriesState {
  final List<String> categories;
  final bool isLoading;
  CategoriesState({this.categories = const [], this.isLoading = false});
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  CategoriesNotifier() : super(CategoriesState());

  Future<void> fetchCategories() async {
    // This is a placeholder implementation
    if (state.isLoading) return;
    state = CategoriesState(isLoading: true, categories: state.categories);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    var moreCategories = List.generate(
        5, (index) => 'Category ${state.categories.length + index + 1}');
    state = CategoriesState(
        categories: List.from(state.categories)..addAll(moreCategories),
        isLoading: false);
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>(
        (ref) => CategoriesNotifier());
