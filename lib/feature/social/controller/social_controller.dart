import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/utils/snackbar.dart';
import 'package:com.while.while_app/feature/social/repository/social_repositroy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialControllerProvider =
    StateNotifierProvider<SocialController, bool>((ref) {
  return SocialController(socialRepository: ref.read(socialRepositoryProvider));
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

  SocialController({required SocialRepository socialRepository})
      : _socialRepository = socialRepository,
        super(false);
  Stream<QuerySnapshot<Object>> peopleStream() =>
      _socialRepository.peopleStream();
  Stream<QuerySnapshot<Object>> followingStream(String id) =>
      _socialRepository.followingStream(id);

  void postStatus(File imageFile, String statText, BuildContext context) async {
    state = true;
    final response = await _socialRepository.postStatus(imageFile, statText);
    state = false;
    response.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, r);
      Navigator.of(context).pop();
    });
  }
}
