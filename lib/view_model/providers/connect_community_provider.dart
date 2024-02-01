import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/add_quiz.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/resources/components/message/models/community_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allCommunitiesProvider = StreamProvider<List<Community>>((ref) {
  return FirebaseFirestore.instance
      .collection('communities')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Community.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  });
});
final joinedCommuntiesProvider =
    StreamProvider.family<Set<String>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('my_communities')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.id).toSet();
  });
});

final joinCommunityProvider = Provider((ref) {
  return (String currentUserId, String communityIdToJoin) async {
    try {
      // Add the user to the 'my_users' subcollection of the current user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('my_communities')
          .doc(communityIdToJoin)
          .set({'timeStamp': Timestamp.now()});
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(currentUserId)
      //     .collection('following')
      //     .doc(communityIdToJoin)
      //     .set({'timeStamp': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityIdToJoin)
          .collection('participants')
          .doc(currentUserId)
          .set(APIs.me.toJson())
        .then((value) => firestore
                .collection('communities')
                .doc(communityIdToJoin)
                .collection('participants')
                .doc(currentUserId)
                .update({
              'easyQuestions': 0,
              'mediumQuestions': 0,
              'hardQuestions': 0,
              'attemptedEasyQuestion': 0,
              'attemptedMediumQuestion': 0,
              'attemptedHardQuestion': 0,
            }));

      return true; // Indicate the follow action was successful
    } catch (e) {
      // If there's an error, you can handle it here
      return false; // Indicate the follow action failed
    }
  };
});
