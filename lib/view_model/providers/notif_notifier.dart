import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/components/message/apis.dart';
import 'package:com.while.while_app/view_model/providers/notif_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState());

  Future<void> fetchNotifications(Ref ref) async {
    // Existing logic remains for fetching all notifications
    // Assume 'isRead' field is used to determine new notifications
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(ref.read(apisProvider).me.id)
        .collection('notifs')
        .orderBy('timeStamp', descending: true)
        .limit(100)
        .get();

    final notifications = snapshot.docs
        .map((doc) => doc.data()['notificationText'] as String)
        .toList();

    // Calculate if there are any new notifications
    bool hasNew = snapshot.docs.any((doc) => !(doc.data()['isRead'] as bool));

    state = NotificationsState(
        notifications: notifications, hasNewNotifications: hasNew);
  }

  Future<void> markNotificationsAsRead(Ref ref) async {
    // Fetch all unread notifications
    var collection = FirebaseFirestore.instance
        .collection('notifications')
        .doc(ref.read(apisProvider).me.id)
        .collection('notifs')
        .where('isRead', isEqualTo: false);

    var snapshots = await collection.get();

    // Batch update to mark as read
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // After marking as read, update state
    await fetchNotifications(ref); // Refresh notifications state
  }
}
