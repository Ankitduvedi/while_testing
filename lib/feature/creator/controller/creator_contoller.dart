import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/core/enums/firebase_providers.dart';
import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.example.while_app/feature/creator/repository/creator_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUserStreamProvider = StreamProvider<DocumentSnapshot>((ref) {
  return ref
      .read(fireStoreProvider)
      .collection('users')
      .doc(ref.read(userProvider)!.id)
      .snapshots();
});
final creatorControllerProvider =
    StateNotifierProvider<CreatorController, bool>((ref) {
  return CreatorController(
      creatorRepository: ref.read(creatorRepositoryProvider), ref: ref);
});

class CreatorController extends StateNotifier<bool> {
  final CreatorRepository _creatorRepository;
  final Ref _ref;

  CreatorController(
      {required CreatorRepository creatorRepository, required Ref ref})
      : _creatorRepository = creatorRepository,
        _ref = ref,
        super(false);

  void submitCreatorRequest(
      String userId, String instagramLink, String youtubeLink) async {
    state = true;
    final response = await _creatorRepository.submitCreatorRequest(
        userId: userId, instagramLink: instagramLink, youtubeLink: youtubeLink);

    response.fold((l) => SnackBar(content: Text(l.message)),
        (r) => const Text("Request Submiited Successfully"));
    state = false;
  }
}
