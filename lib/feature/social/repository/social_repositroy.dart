import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/providers/follower_provider.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(firestore: ref.read(fireStoreProvider), ref: ref);
});

class SocialRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  SocialRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

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

  Future<Either<Failure, String>> postStatus(
      File imageFile, String statText) async {
    try {
      final userId =
          _ref.read(userProvider)!.id; // Replace with the actual user's ID

      // Upload the image to Firebase Storage
      final storageReference = _ref
          .read(firebaseStorageProvider)
          .ref()
          .child('$userId/${DateTime.now()}.png');
      await storageReference.putFile(imageFile);

      // Get the image URL from Firebase Storage
      final imageUrl = await storageReference.getDownloadURL();

      FirebaseFirestore.instance.collection('statuses').add({
        'userId': userId,
        'userName': _ref.read(userProvider)!.name,
        'profileImg': _ref.read(userProvider)!.image,
        'statusText': statText,
        'imageUrl': imageUrl, // Add the URL of the uploaded image
        'timestamp': FieldValue.serverTimestamp(),
      });
      return right("Successfully added status");
    } catch (e) {
      return left(Failure(message: "Unable to add status"));
    }
  }
}
