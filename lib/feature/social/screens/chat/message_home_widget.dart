import 'dart:developer';

import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/social/screens/chat/chat_user_card.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
              return Center(
                child: Text(
                  'No Data Found',
                  style: GoogleFonts.ptSans(color: Colors.black),
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
