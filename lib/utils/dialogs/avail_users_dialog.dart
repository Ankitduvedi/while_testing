// import 'package:com.example.while_app/data/model/chat_user.dart';
// import 'package:com.example.while_app/resources/components/message/apis.dart';
// import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class UserListDialog extends ConsumerWidget {
//   final String commId;
//   final List<ChatUser> list;

//   const UserListDialog({super.key, required this.commId, required this.list});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final allUsersAsyncValue = ref.watch(allUsersProvider);
//     final myUsersAsyncValue = ref.watch(myUsersUidsProvider);
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: allUsersAsyncValue.when(
//           data: (allUsers) => myUsersAsyncValue.when(
//             data: (followingUsers) {
//               // Extract user IDs from 'list' into a Set for efficient lookup
//               final listUserIds = list.map((user) => user.id).toSet();

// // Filter 'allUsers' to get 'notAddedUsers' based on IDs not being in 'listUserIds'
//               final notAddedUsers = allUsers
//                   .where((user) => !listUserIds.contains(user.id))
//                   .toList();

//               final usersList = followingUsers
//                   .map((userId) => notAddedUsers.firstWhere(
//                         (user) => user.id == userId,
//                         orElse: () => ChatUser
//                             .empty(), // Provide a fallback value to avoid the error
//                       ))
//                   .toList();

//               if (usersList.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No Data Found',
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 );
//               }
//               return ListView.builder(
//                 itemCount: usersList.length,
//                 itemBuilder: (context, index) {
//                   return Column(
//                     children: [
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(usersList[index].image),
//                         ),
//                         title: Text(usersList[index].name),
//                         subtitle: Text(usersList[index].email),
//                         onTap: () async {
//                           await APIs.AdminAddUserToCommunity(
//                               commId, usersList[index].id, usersList[index]);
//                           // Do something when a user is tapped
//                         },
//                       ),
//                       Divider(
//                         color: Colors.grey.shade300,
//                         thickness: 1,
//                         height: 0,
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             loading: () => const Center(child: CircularProgressIndicator()),
//             error: (e, _) => Center(child: Text('Error: $e')),
//           ),
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (e, _) => Center(child: Text('Error: $e')),
//         ));
//   }
// }
import 'dart:developer';

import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListDialog extends ConsumerWidget {
  final String commId;

  final List<ChatUser> list;

  const UserListDialog({super.key, required this.commId, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggle = ref.watch(toggleSearchStateProvider);
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    final followingUsersAsyncValue =
        ref.watch(communityParticipantsProvider(commId));

    return Scaffold(
      body: allUsersAsyncValue.when(
        data: (allUsers) => followingUsersAsyncValue.when(
          data: (followingUsers) {
            log('list of users ${followingUsers.toString()}');
            final nonFollowingUsers = allUsers
                .where((user) => !followingUsers.contains(user.id))
                .toList();
            log('length of all participants ${followingUsers.length}');

            log('length of all users ${allUsers.length}');

            log('length of non participants users ${nonFollowingUsers.length}');

            return ListView.builder(
              itemCount: nonFollowingUsers.length,
              itemBuilder: (context, index) {
                final user = nonFollowingUsers[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // final didFollow = await ref.read(followUserProvider)(
                      //     APIs.me.id, user.id);

                      await ref.read(apisProvider).adminAddUserToCommunity(commId, user);
                    },
                    child: const Text('Add'),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
