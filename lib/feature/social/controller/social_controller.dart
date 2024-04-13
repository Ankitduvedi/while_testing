import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/utils/utils.dart';
import 'package:com.while.while_app/data/model/community_message.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/social/repository/social_repositroy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialControllerProvider =
    StateNotifierProvider<SocialController, bool>((ref) {
  return SocialController(
      socialRepository: ref.read(socialRepositoryProvider), ref: ref);
});
final peopleStreamProvider = StreamProvider<QuerySnapshot<Object>>((ref) {
  final socialController = ref.watch(socialControllerProvider.notifier);
  // Provide an empty stream as a fallback in case peopleStream() returns null
  return socialController.peopleStream();
});
final followingStreamProvider =
    StreamProvider.family<QuerySnapshot<Object>, String>((ref, id) {
  final socialController = ref.watch(socialControllerProvider.notifier);
  return socialController.followingStream(id);
});

class SocialController extends StateNotifier<bool> {
  final SocialRepository _socialRepository;
  final Ref _ref;

  SocialController(
      {required SocialRepository socialRepository, required Ref ref})
      : _socialRepository = socialRepository,
        _ref = ref,
        super(false);
  Stream<QuerySnapshot<Object>> peopleStream() =>
      _socialRepository.peopleStream();
  Stream<QuerySnapshot<Object>> followingStream(String id) =>
      _socialRepository.followingStream(id);

  void sendCommunityMessage(
      String id, String msg, Types type, BuildContext context) async {
    state = true;
    await _socialRepository.sendCommunityMessage(id, msg, type);

    state = false;
  }

  void communitySendChatImage(
      Community chatUser, File file, BuildContext context) async {
    state = true;
    final res = await _socialRepository.communitySendChatImage(chatUser, file);
    res.fold((l) => Utils.snackBar(l.message, context), (r) {
      _ref
          .read(socialControllerProvider.notifier)
          .sendCommunityMessage(r.chatId, r.imageUrl, r.type, context);
      Utils.snackBar("Message sent to ${r.chatId}", context);
    });
    state = false;
  }
}
