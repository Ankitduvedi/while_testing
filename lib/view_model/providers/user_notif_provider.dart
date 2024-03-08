import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .doc(APIs.me.id)
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
