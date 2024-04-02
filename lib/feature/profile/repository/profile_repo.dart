import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
// import 'package:while_app/utils/snackbar.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(firestore: ref.read(fireStoreProvider), ref: ref);
});

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;
  ProfileRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  Future<Either<Failure, ChatUser>> updateUserData(ChatUser updatedUser) async {
    try {
      final uid = _ref.read(userProvider)?.id;
      await _firestore.collection('users').doc(uid).set(updatedUser.toJson());
      return right(updatedUser);
    } on FirebaseAuthException catch (e) {
      log(e.toString()); // Log the error for debugging
      return left(Failure(message: "FirebaseAuthException: ${e.message}"));
    } catch (error) {
      log('Error updating user data: $error');
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, String>> updateProfilePicture(File file) async {
    //getting image file extension
    try {
      final ext = file.path.split('.').last;
      log('Extension: $ext');

      final reference = _ref
          .read(firebaseStorageProvider)
          .ref()
          .child('profile_pictures/${_ref.read(userProvider)!.id}.$ext');

      //uploading image
      await reference
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });
      //updating image in firestore database
      final userImage = await reference.getDownloadURL();
      await _firestore
          .collection('users')
          .doc(_ref.read(userProvider)!.id)
          .update({'image': userImage});
      return right(userImage);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
