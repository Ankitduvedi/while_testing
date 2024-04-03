import 'dart:developer';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/feature/social/controller/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListDialog extends ConsumerWidget {
  final String commId;

  final List<ChatUser> list;

  const UserListDialog({super.key, required this.commId, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final toggle = ref.watch(toggleSearchStateProvider);
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

                      await ref
                          .read(apisProvider)
                          .adminAddUserToCommunity(commId, user);
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
