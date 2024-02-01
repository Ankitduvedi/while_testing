import 'package:com.example.while_app/resources/components/communities/chat_user_card.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageHomeWidget extends ConsumerWidget {
  const MessageHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    final myUsersAsyncValue = ref.watch(myUsersUidsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: allUsersAsyncValue.when(
        data: (allUsers) => myUsersAsyncValue.when(
          data: (followingUsers) {
            final nonFollowingUsers = followingUsers
                .map((userId) =>
                    allUsers.firstWhere((user) => user.id == userId))
                .toList();
            return ListView.builder(
              itemCount: nonFollowingUsers.length,
              itemBuilder: (context, index) {
                return ChatUserCard(user: nonFollowingUsers[index]);
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
