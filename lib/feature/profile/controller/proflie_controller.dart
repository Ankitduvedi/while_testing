import 'dart:developer';
import 'dart:io';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/profile/repository/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profilerControllerProvider =
    StateNotifierProvider<ProfileController, bool>((ref) {
  return ProfileController(
      ref: ref, profileRepository: ref.read(profileRepositoryProvider));
});

class ProfileController extends StateNotifier<bool> {
  final ProfileRepository _profileRepository;
  final Ref _ref;
  ProfileController(
      {required Ref ref, required ProfileRepository profileRepository})
      : _ref = ref,
        _profileRepository = profileRepository,
        super(false);

  void updateUserData(ChatUser updatedUser, BuildContext context) async {
    state = true;
    final profile = await _profileRepository.updateUserData(updatedUser);
    state = false;
    log("updating user with new user data the provider");
    profile.fold((l) => Failure(message: "Failed Updating"),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
  }

  void updateProfilePicture(File file, BuildContext context) async {
    state = true;
    final imageUrl = await _profileRepository.updateProfilePicture(file);
    log("updating provider data");
    imageUrl.fold(
        (l) => Failure(message: l.message),
        (r) => _ref
            .read(userProvider.notifier)
            .update((state) => state!.copyWith(image: r)));
    state = false;
  }
}
