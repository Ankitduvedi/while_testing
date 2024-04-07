// ignore_for_file: unused_field
import 'package:com.while.while_app/feature/creator/repository/creator_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
