// ignore_for_file: unused_field

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final creatorRepositoryProvider = Provider<CreatorRepository>((ref) {
  return CreatorRepository(firestore: ref.read(fireStoreProvider), ref: ref);
});

class CreatorRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  CreatorRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  Future<Either<Failure, bool>> submitCreatorRequest({
    required String userId,
    required String instagramLink,
    required String youtubeLink,
  }) async {
    try {
      Timestamp requestTime = Timestamp.fromDate(DateTime.now());

      // Create the request document in Firestore under 'requests' collection
      await _firestore.collection('requests').doc(userId).set({
        'userId': userId,
        'isContentCreator': 0, // Assuming this means the request is pending
        'timeStamp': requestTime,
        'instagramLink': instagramLink,
        'youtubeLink': youtubeLink,
        'isApproved': 1, // Initially, the request is not approved
      });
      // Update 'isApproved' in the 'users' collection for the user
      await _firestore.collection('users').doc(userId).update({
        'isApproved':
            1, // Update this field based on your logic, false if you're awaiting approval
      });
      log("User and request submitted successfully");
      return right(true);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
