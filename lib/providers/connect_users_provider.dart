import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allUsersProvider = StreamProvider<List<ChatUser>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final toggle = ref.watch(toggleSearchStateProvider);

  log('///////////');
   return FirebaseFirestore.instance
    .collection('users')
    .snapshots()
    .handleError((error) {
      log('Error fetching users: $error');
      return const Stream.empty();  // Return an empty stream on error.
    })
    .map((snapshot) {
      var users = snapshot.docs.map((doc) => ChatUser.fromJson(doc.data())).toList();
      log('allUsersProvider user length ${users.length}');
      if (toggle == 1 && searchQuery != '') {
        return users.where((user) => user.name.toLowerCase().contains(searchQuery)).toList();
      } else {
        return users;
      }
    });

});
// this provider is for search users
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

final filteredUsersProvider = Provider<List<ChatUser>>((ref) {
  // Get the current search query
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  // Get the list of all users
  final allUsers = ref.watch(allUsersProvider).asData?.value ?? [];

  // Filter users based on the search query
  return allUsers.where((user) {
    return user.name.toLowerCase().contains(searchQuery) ||
        user.email.toLowerCase().contains(searchQuery);
  }).toList();
});

///
final myUsersUidsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(ref.read(userProvider)!.id)
      .collection('my_users')
      .orderBy('timeStamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});
final followingUsersProvider =
    StreamProvider.family<List<String>, String>((ref, userId) {
  // final user = ref.watch(userDataProvider).userData;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('following')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.id).toList();
  });
});
final communityParticipantsProvider =
    StreamProvider.family<List<String>, String>((ref, communityId) {
  // final user = ref.watch(userDataProvider).userData;
  return FirebaseFirestore.instance
      .collection('communities')
      .doc(communityId)
      .collection('participants')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.id).toList();
  });
});

final followUserProvider = Provider((ref) {
  return (String userIdToFollow) async {
    final String currentUserId = ref.read(userProvider)!.id;
    try {
      // Add the user to the 'my_users' subcollection of the current user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(userIdToFollow)
          .set({'timeStamp': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userIdToFollow)
          .set({'timeStamp': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdToFollow)
          .collection('follower')
          .doc(currentUserId)
          .set({'timeStamp': Timestamp.now()});

      return true; // Indicate the follow action was successful
    } catch (e) {
      // If there's an error, you can handle it here
      return false; // Indicate the follow action failed
    }
  };
});
