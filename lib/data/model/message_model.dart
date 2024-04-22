// import 'package:cloud_firestore/cloud_firestore.dart';

// class Message {
//   final String id;
//   final String content;  // Assuming there's a 'content' field in your messages
//   final DateTime sentTime;

//   Message({required this.id, required this.content, required this.sentTime});

//   factory Message.fromMap(Map<String, dynamic> map, String id) {
//     return Message(
//       id: id,
//       content: map['content'] ?? "",
//       sentTime: (map['sent'] as Timestamp).toDate(),
//     );
//   }
// }
