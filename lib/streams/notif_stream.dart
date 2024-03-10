import 'package:cloud_firestore/cloud_firestore.dart';

Stream<int> listenToUnreadNotifications(String userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .doc(userId)
      .collection('notifs')
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length); // Returns the count of unread notifications
}
