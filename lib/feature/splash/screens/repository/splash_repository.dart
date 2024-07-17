import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/constant.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/core/secure_storage/saving_data.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepository(firestore: ref.read(fireStoreProvider), ref: ref);
});

class SplashRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;
  SplashRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  Future<Either<Failure, bool>> intializeWhile() async {
    try {
      final versionNumber = await getAppVersion();
      final reviewVersionNumber = await getAppReviewVersion();
      debugPrint(
          "version number is $versionNumber and review version number is $reviewVersionNumber");
      if (versionNumber != version && reviewVersionNumber != version) {
        return right(true);
      }
      return right(false);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<String> getAppVersion() async {
    try {
      final data = _firestore
          .collection("versions")
          .doc(Platform.isAndroid ? "Android" : "iOS");
      final document = await data.get();
      return document["version"].toString();
    } catch (e) {
      return version;
    }
  }

  Future<String> getAppReviewVersion() async {
    try {
      final platform = (Platform.isAndroid ? "Android" : "iOS");
      final data = _firestore.collection("review_version").doc(platform);
      final document = await data.get();

      if (document.exists) {
        return document.data()!["version"].toString();
      } else {
        throw Exception("Document not found");
      }
    } catch (e) {
      return "Unknown App Update Error $e";
    }
  }

  Future<Either<Failure, int>> checkCondition() async {
    try {
      final tempaccessToken =
          await SecureStorage().getUserAccessToken('tempAccessToken');

      if (tempaccessToken != 'onboarded') {
        SecureStorage().setUserAccessToken('tempAccessToken', 'onboarded');
        return right(1);
      } else {
        final accessToken =
            await SecureStorage().getUserAccessToken('accessToken');
        if (accessToken != '') {
          return right(2);
        } else {
          _ref.read(userDataProvider).userData;
          return right(3);
        }
      }
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
