import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Connect extends ConsumerWidget {
  const Connect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // Assume the current user ID is available
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    final followingUsersAsyncValue = ref.watch(followingUsersProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Users')),
      body: allUsersAsyncValue.when(
        data: (allUsers) => followingUsersAsyncValue.when(
          data: (followingUsers) {
            final nonFollowingUsers = allUsers
                .where((user) => !followingUsers.contains(user.id))
                .toList();

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
                      // Assuming 'user' is the ChatUser instance you want to follow
                      final userProvider = ref.watch(userDataProvider);

                      // Use the provider to follow the user
                      final didFollow = await ref.read(followUserProvider)(
                          APIs.me.id, user.id);

                      if (didFollow) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You are now following ${user.name}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to follow ${user.name}')),
                        );
                      }
                    },
                    child: const Text('Follow'),
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
