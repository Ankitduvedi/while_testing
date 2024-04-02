import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/components/communities/quiz/add_quiz.dart';
import 'package:com.while.while_app/components/message/apis.dart';
import 'package:com.while.while_app/data/model/community_message.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allCommunitiesProvider = StreamProvider<List<Community>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final toggle = ref.watch(toggleSearchStateProvider);
  return FirebaseFirestore.instance
      .collection('communities')
      .orderBy('timeStamp', descending: true)
      .snapshots()
      .map((snapshot) {
    var communityList =
        snapshot.docs.map((doc) => Community.fromJson(doc.data())).toList();
    if (toggle == 100 && searchQuery != '') {
      return communityList
          .where(
              (community) => community.name.toLowerCase().contains(searchQuery))
          .toList();
    } else {
      return communityList;
    }
  });
});
final myCommunityUidsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(ref.read(userProvider)!.id)
      .collection('my_communities')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
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
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityIdToJoin)
          .collection('participants')
          .doc(currentUserId)
          .set(ref.read(apisProvider).me.toJson())
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
      ref.read(apisProvider).sendCommunityMessage(
          communityIdToJoin,
          '${ref.read(apisProvider).me.name} joined the community',
          Types.joined);
      return true; // Indicate the follow action was successful
    } catch (e) {
      // If there's an error, you can handle it here
      return false; // Indicate the follow action failed
    }
  };
});
