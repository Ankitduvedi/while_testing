import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(firestore: ref.read(fireStoreProvider));
});

class SocialRepository {
  final FirebaseFirestore _firestore;

  SocialRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<QuerySnapshot<Object>> peopleStream() {
    return _firestore
        .collection('statuses')
        .orderBy('userId')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Object>> followingStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('my_users')
        .snapshots();
  }
}
