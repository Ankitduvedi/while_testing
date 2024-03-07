import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view_model/providers/notif_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState());

  Future<void> fetchNotifications() async {
    // Fetch notifications from Firestore and update state
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(APIs.me.id)
        .collection('notifs')
        .orderBy('timeStamp', descending: true)
        .limit(100)
        .get();

    final notifications = snapshot.docs.map((doc) => doc.data()['notificationText'] as String).toList();

    // Update state with fetched notifications
    // You could also set hasNewNotifications based on some logic here
    state = NotificationsState(notifications: notifications, hasNewNotifications: true);
  }

  void markNotificationsAsRead() {
    // When the user views notifications, mark them as read and update state
    state = NotificationsState(notifications: state.notifications, hasNewNotifications: false);
  }
}
// Define a provider for the notifications logic
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});