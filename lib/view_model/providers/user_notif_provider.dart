import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myNotificationsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .doc(APIs.me.id)
      .collection('notifs')
      .orderBy('timeStamp',
          descending: true) // Order by timestamp, latest first
      .limit(100) // Limit to top 100
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      // Assuming each document has a 'text' field you want to extract
      return doc.data()['notificationText'] as String;
    }).toList();
  });
});
