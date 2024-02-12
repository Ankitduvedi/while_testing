import 'dart:developer';

import 'package:com.example.while_app/resources/components/communities/chat_user_card.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageHomeWidget extends ConsumerWidget {
  const MessageHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    final myUsersAsyncValue = ref.watch(myUsersUidsProvider);
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    return Scaffold(
      backgroundColor: Colors.white,
      body: allUsersAsyncValue.when(
        data: (allUsers) => myUsersAsyncValue.when(
          data: (followingUsers) {
            final nonFollowingUsers = followingUsers
                .map((userId) => allUsers.firstWhere(
                      (user) => user.id == userId,
                      orElse: () => ChatUser
                          .empty(), // Provide a fallback value to avoid the error
                    ))
                .toList();
            var usersList = toogleSearch == 2
                ? nonFollowingUsers
                    .where(
                        (user) => user.name.toLowerCase().contains(searchQuery))
                    .toList()
                : nonFollowingUsers;

            log(usersList.length.toString());
            log('usersList.length.toString()');
            if (usersList.isEmpty) {
              return const Center(
                child: Text(
                  'No Data Found',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
            return ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ChatUserCard(user: usersList[index]),
                    Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                          height: 0,
                        ),
                  ],
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
