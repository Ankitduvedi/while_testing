import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/social/screens/chat/chat_user_card.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/main.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageHomeWidget extends ConsumerWidget {
  const MessageHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(ref.read(userDataProvider).userData!.id)
        .update({'isChattingWith': activeChatUserId});
    log("chatScreen");
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    var user = ref.watch(userDataProvider).userData!;
    user = ref.watch(userDataProvider).userData!;
    final myUsersAsyncValue = ref.watch(myUsersUidsProvider(user.id));
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
            // print("nonflowers ${nonFollowingUsers[0].toJson()}");
            var usersList = toogleSearch == 2
                ? nonFollowingUsers
                    .where(
                        (user) => user.name.toLowerCase().contains(searchQuery))
                    .toList()
                : nonFollowingUsers;

            log("chatusers length ${usersList.length}");
            // log('usersList.length.toString()');
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
          error: (e, _) => Center(child: Text('Error1: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error2: $e')),
      ),
    );
  }
}
