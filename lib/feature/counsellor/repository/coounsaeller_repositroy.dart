import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/counsellor/models/categories_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final counsellerRepositoryProvider = Provider<CounsellerRepository>((ref) {
  return CounsellerRepository(firestore: ref.read(fireStoreProvider), ref: ref);
});

class CounsellerRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  CounsellerRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  Future<Either<Failure, bool>> submitCounsellerRequest({
    required List<CategoryInfo> allCategoriesInfo,
  }) async {
    try {
      Timestamp requestTime = Timestamp.fromDate(DateTime.now());
      final user = _ref.read(userProvider);
      DocumentReference requestRef =
          _firestore.collection('CounsellerRequests').doc(user!.id);

      // Create the main request document
      await requestRef.set({
        'userId': user.id,
        'isCounsellor': false,
        'timeStamp': requestTime,
        'isCounsellorVerified': true,
      });

      // Iterating through all categories to store each category's information
      for (CategoryInfo info in allCategoriesInfo) {
        await requestRef.collection('Categories').doc(info.category).set({
          'yearsOfExperience': info.yearsOfExperience,
          'organisation': info.organisation,
          'customersCatered': info.customersCatered
        });
      }

      // Optionally update the user's document
      await _firestore.collection('users').doc(user.id).update({
        'isCounsellorVerified': true // Set to false awaiting approval
      });

      log("User and request submitted successfully with all category data.");
      return right(true);
    } catch (e) {
      log("Error submitting counsellor request: ${e.toString()}");
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> checkIfUserDocumentExists(
      String userId, String docId) async {
    try {
      // Reference to the nested document
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users') // Main collection
          .doc(userId) // Main document ID
          .collection('following') // Sub-collection
          .doc(docId) // Document ID you are checking for
          .get();

      // Returns true if the document exists
      return right(documentSnapshot.exists);
    } catch (e) {
      // Handle any exceptions here, possibly logging the error
      return left(Failure(message: e.toString()));
    }
  }
}
