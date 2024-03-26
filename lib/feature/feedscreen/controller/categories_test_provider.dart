import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>(
        (ref) => CategoriesNotifier());

final allVideoProvider = StateNotifierProvider.family<VideoPaginationNotifier,
    VideoPaginationState, String>(
  (ref, collectionPath) => VideoPaginationNotifier(),
);
final categoryStreamProvider = StreamProvider<List<String>>((ref) {
  final firestore = ref.read(fireStoreProvider);
  return firestore
      .collection('videosCategories')
      .orderBy('category')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

// Define a state class that includes a list of categories and pagination control variables
class CategoriesState {
  final List<String> categories;
  final bool isLoading;
  final DocumentSnapshot? lastDocument; // Last fetched document for pagination

  CategoriesState(
      {this.categories = const [], this.isLoading = false, this.lastDocument});

  CategoriesState copyWith({
    List<String>? categories,
    bool? isLoading,
    DocumentSnapshot? lastDocument,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

// Define a StateNotifier for categories with pagination
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  CategoriesNotifier() : super(CategoriesState());

  Future<void> fetchCategories(WidgetRef ref) async {
    if (state.isLoading) return; // Prevent fetching if already loading
    state = state.copyWith(isLoading: true);

    Query query = ref
        .read(fireStoreProvider)
        .collection('videosCategories')
        .orderBy(
            'category') // Assuming categories are ordered by a 'name' field
        .limit(5); // Adjust the limit as needed

    // Use the lastDocument for pagination if available
    if (state.lastDocument != null) {
      query = query.startAfterDocument(state.lastDocument!);
    }

    try {
      var snapshot = await query.get();
      var docs = snapshot.docs;
      if (docs.isNotEmpty) {
        var newCategories = docs.map((doc) => doc.id).toList();
        state = state.copyWith(
          categories: List.from(state.categories)..addAll(newCategories),
          lastDocument: docs.last,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false); // No more data to fetch
      }
    } catch (error) {
      state = state.copyWith(isLoading: false); // Handle error state
      // Optionally log or handle the error
    }
  }
}

class VideoPaginationState {
  final List<Video> videos;
  final bool isLoading;
  final DocumentSnapshot? lastDoc;

  VideoPaginationState({
    this.videos = const [],
    this.isLoading = false,
    this.lastDoc,
  });
  VideoPaginationState copyWith({
    List<Video>? videos,
    bool? isLoading,
    DocumentSnapshot? lastDoc,
  }) {
    return VideoPaginationState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      lastDoc: lastDoc ?? this.lastDoc,
    );
  }
}

class VideoPaginationNotifier extends StateNotifier<VideoPaginationState> {
  VideoPaginationNotifier() : super(VideoPaginationState());

  final int _limit = 3; // Number of documents to fetch per batch

  Future<void> fetchVideos(String collectionPath) async {
    if (state.isLoading) return; // Prevent multiple simultaneous fetches
    state = state.copyWith(isLoading: true);
    log(collectionPath);
    Query query = FirebaseFirestore.instance
        .collection('videos')
        .doc(collectionPath)
        .collection(collectionPath)
        // .orderBy('title') // Adjust based on your document fields
        .limit(_limit);

    if (state.lastDoc != null) {
      query = query.startAfterDocument(state.lastDoc!);
    }

    try {
      final snapshot = await query.get();
      log("snapsjhot is ${snapshot.docs.first.id}");
      var docs = snapshot.docs;
      if (docs.isNotEmpty) {
        var newCategories = docs
            .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          videos: List.from(state.videos)..addAll(newCategories),
          lastDoc: docs.last,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false); // No more data to fetch
      }
    } catch (e) {
      // Handle errors, e.g., by logging or setting an error state
      state = VideoPaginationState(
          videos: state.videos, isLoading: false, lastDoc: state.lastDoc);
    }
  }
}
