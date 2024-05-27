import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider = StreamProvider<List<String>>((ref) {
  final categoriesStream = FirebaseFirestore.instance
      .collection('videosCategories')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toList());

  return categoriesStream;
});
