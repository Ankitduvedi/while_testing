// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/feature/notifications/repository/notif_repo.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listenUnreadNotifsProvider = StreamProvider<int>((ref) {
  return ref
      .read(fireStoreProvider)
      .collection('notifications')
      .doc(ref.read(userDataProvider).userData!.id)
      .collection('notifs')
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final myNotificationsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref
      .read(fireStoreProvider)
      .collection('notifications')
      .doc(ref.read(userDataProvider).userData!.id)
      .collection('notifs') // Filter for unread notifications
      .orderBy('timeStamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'notificationText': doc.data()['notificationText'] as String,
        'timeStamp': doc.data()['timeStamp'] as Timestamp,
      };
    }).toList();
  });
});

final notifControllerProvider =
    StateNotifierProvider<NotifController, bool>((ref) {
  return NotifController(
      ref: ref, notifRepository: ref.read(notifRepositoryProvider));
});

class NotifController extends StateNotifier<bool> {
  final Ref _ref;
  final NotifRepository _notifRepository;
  NotifController({required Ref ref, required NotifRepository notifRepository})
      : _notifRepository = notifRepository,
        _ref = ref,
        super(false); //to tell it is in loading state

  void addNotification(String notificationText, String userId) async {
    state = true;
    final response =
        await _notifRepository.addNotification(notificationText, userId);
    state = false;
    response.fold((l) => SnackBar(content: Text(l.message)), (r) => null);
  }

  void markAllNotificationsRead() async {
    state = true;
    final response = await _notifRepository.markAllNotificationsAsRead();
    state = false;
    response.fold((l) => SnackBar(content: Text(l.message)), (r) => null);
  }
}
