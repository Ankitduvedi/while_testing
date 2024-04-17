// ignore_for_file: unused_field
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/feature/counsellor/models/categories_info.dart';
import 'package:com.while.while_app/feature/counsellor/repository/coounsaeller_repositroy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counsellorContollerProvider =
    StateNotifierProvider<CounsellorContoller, bool>((ref) {
  return CounsellorContoller(
      counsellerRepository: ref.read(counsellerRepositoryProvider), ref: ref);
});
final counsellerDetailsProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, counsellorId) {
  log("fetching");
  return ref
      .read(fireStoreProvider)
      .collection('counsellers')
      .doc(counsellorId)
      .collection('counsellersData')
      .snapshots();
});

final particularUser =
    FutureProvider.family<DocumentSnapshot, String>((ref, userId) {
  return ref.read(fireStoreProvider).collection('users').doc(userId).get();
});

class CounsellorContoller extends StateNotifier<bool> {
  final CounsellerRepository _counsellorRepository;
  final Ref _ref;

  CounsellorContoller(
      {required CounsellerRepository counsellerRepository, required Ref ref})
      : _counsellorRepository = counsellerRepository,
        _ref = ref,
        super(false);

  void submitCounsellerRequest(List<CategoryInfo> allCategoriesInfo) async {
    state = true;
    final response = await _counsellorRepository.submitCounsellerRequest(
        allCategoriesInfo: allCategoriesInfo);

    response.fold((l) => SnackBar(content: Text(l.message)),
        (r) => const Text("Request Submiited Successfully"));
    state = false;
  }
}
