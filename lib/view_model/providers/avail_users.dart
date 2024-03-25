import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myUsersProvider = StreamProvider<List<ChatUser>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(ref.read(apisProvider).me.id)
      .collection('my_users')
      .snapshots()
      .asyncMap((snapshot) async {
    List<ChatUser> users = [];
    for (var doc in snapshot.docs) {
      var userDetailsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .get();

      var userDetail = ChatUser(
          isContentCreator: userDetailsDoc['isContentCreator'],
          isApproved: userDetailsDoc['isApproved'],
          image: userDetailsDoc['image'],
          about: userDetailsDoc['about'],
          name: userDetailsDoc['name'],
          createdAt: userDetailsDoc['created_at'],
          isOnline: userDetailsDoc['is_online'],
          id: userDetailsDoc['id'],
          lastActive: userDetailsDoc['last_active'],
          email: userDetailsDoc['email'],
          pushToken: userDetailsDoc['push_token'],
          dateOfBirth: userDetailsDoc['dateOfBirth'],
          gender: userDetailsDoc['gender'],
          phoneNumber: userDetailsDoc['phoneNumber'],
          place: userDetailsDoc['place'],
          profession: userDetailsDoc['profession'],
          designation: userDetailsDoc['designation'],
          follower: userDetailsDoc['follower'],
          easyQuestions: userDetailsDoc['easyQuestions'],
          mediumQuestions: userDetailsDoc['mediumQuestions'],
          hardQuestions: userDetailsDoc['hardQuestions'],
          lives: userDetailsDoc['lives'],
          following: userDetailsDoc['following']);

      users.add(userDetail);
    }
    return users;
  });
});
