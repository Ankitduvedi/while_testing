import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoStreamProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((
  ref,
) {
  return FirebaseFirestore.instance.collection('loops').snapshots();
});

class DataProvider extends ChangeNotifier {
  // Your Firestore stream
  final Stream<QuerySnapshot> _videoStream =
      FirebaseFirestore.instance.collection('loops').snapshots();
  Stream<QuerySnapshot> get videoStream => _videoStream;
  // Private constructor to prevent instantiation from outside
  DataProvider._();
  static final DataProvider _instance = DataProvider._();
  factory DataProvider() => _instance;
}

///////
///
class LoopsState {
  final List<Video> loops;
  final bool isLoading;
  final DocumentSnapshot? lastDocument; // Last fetched document for pagination

  LoopsState(
      {this.loops = const [], this.isLoading = false, this.lastDocument});

  LoopsState copyWith({
    List<Video>? loops,
    bool? isLoading,
    DocumentSnapshot? lastDocument,
  }) {
    return LoopsState(
      loops: loops ?? this.loops,
      isLoading: isLoading ?? this.isLoading,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

// Define a StateNotifier for categories with pagination
class LoopsNotifier extends StateNotifier<LoopsState> {
  LoopsNotifier() : super(LoopsState());

  Future<void> fetchLoops() async {
    log("length of loops in before fetcgloops b${state.isLoading}");

    if (state.isLoading) return; // Prevent fetching if already loading
    state = state.copyWith(isLoading: true);
    log("length of loops in fetcgloops b${state.isLoading}");

    Query query = FirebaseFirestore.instance
        .collection('loops')
        .orderBy('title') // Assuming categories are ordered by a 'name' field
        .limit(2); // Adjust the limit as needed
    log('querry done');
    // Use the lastDocument for pagination if available
    if (state.lastDocument != null) {
      query = query.startAfterDocument(state.lastDocument!);
    }

    try {
      log("trying");
      var snapshot = await query.get();
      var docs = snapshot.docs;
      if (docs.isNotEmpty) {
        var newLoops = docs
            .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          loops: List.from(state.loops)..addAll(newLoops),
          lastDocument: docs.last,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false); // No more data to fetch
      }
    } catch (error) {
      state = state.copyWith(isLoading: false); // Handle error state
      // Optionally log or handle the error
      log("error");
    }
  }
}

final loopsProvider =
    StateNotifierProvider<LoopsNotifier, LoopsState>((ref) => LoopsNotifier());

////// new chatgpt 4
class DataProviderss extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;
  final List<DocumentSnapshot> _allDocuments = [];
  bool _hasMore = true;
  final int _limit = 10; // Adjust based on your preference

  Stream<List<Video>> get videoStream => _firestore
          .collection('loops')
          .orderBy(
              'timestamp') // Assuming you have a timestamp field for ordering
          .startAfterDocument(_lastDocument!)
          .limit(_limit)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          _allDocuments.addAll(snapshot.docs);
        } else {
          _hasMore = false;
        }
        return _allDocuments
            .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });

  // Call this method from your UI to fetch the next batch
  void fetchNextVideos() {
    if (_hasMore) {
      notifyListeners();
    }
  }
}
