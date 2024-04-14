import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/community_message.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/social/screens/community/quizzes/add_quiz.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<Either<Failure, String>> sendCommunityMessage(
      String id, String msg, Types type) async {
    //message sending time (also used as id)
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final user = _ref.read(userProvider);
      //message to send
      final CommunityMessage message = CommunityMessage(
        toId: id,
        msg: msg,
        read: '',
        types: type,
        fromId: user!.id,
        sent: time,
        senderName: user.name,
      );
      log(user.name);

      final ref = _ref
          .read(fireStoreProvider)
          .collection('communities')
          .doc(id)
          .collection('chat');
      await ref.doc(time).set(message.toJson()).then((value) {
        try {
          _ref
              .read(fireStoreProvider)
              .collection('communities')
              .doc(id)
              .update({'timeStamp': time});
        } catch (error) {
          log(error.toString());
        }
      });
      return right("successfully sent message");
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, ChatImageResult>> communitySendChatImage(
      Community chatUser, File file) async {
    //getting image file extension
    try {
      final ext = file.path.split('.').last;

      //storage file ref with path
      final ref = _ref.read(firebaseStorageProvider).ref().child(
          'images/${_ref.read(apisProvider).getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      //uploading image
      await ref
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      final imageUrl = await ref.getDownloadURL();

      return right(ChatImageResult(
          chatId: chatUser.id, imageUrl: imageUrl, type: Types.image));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> removeUserFromCommunity(
      String communityId, String userId) async {
    try {
      await _ref
          .read(fireStoreProvider)
          .collection('communities')
          .doc(communityId)
          .collection('participants')
          .doc(userId)
          .delete();
      return right("Removed User from Community");
    } catch (e, stacktrace) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> uddateDesignation(
      String communityId, String userId, String designation) async {
    try {
      await _ref
          .read(fireStoreProvider)
          .collection('communities')
          .doc(communityId)
          .collection('participants')
          .doc(userId)
          .update({'designation': designation});
      return right("Updated Designation");
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> removeCommunityFromUser(
      String userId, String communityId) async {
    try {
      // Path to the user's specific community document
      DocumentReference communityDoc = firestore
          .collection('users')
          .doc(userId)
          .collection('my_communities')
          .doc(communityId);

      // Perform the delete operation
      await communityDoc.delete();
      return right("Community successfully removed from user's list.");
    } catch (e, stacktrace) {
      return left(Failure(message: e.toString()));
    }
  }
}

class ChatImageResult {
  final String chatId;
  final String imageUrl;
  final Types type;

  ChatImageResult(
      {required this.chatId, required this.imageUrl, required this.type});
}
