import 'dart:developer';

import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view_model/providers/avail_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListDialog extends ConsumerWidget {
  final String commId;
  final String commName;

  const UserListDialog({super.key, required this.commId,required this.commName});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, watch, child) {
      final myUsers = ref.watch(myUsersProvider);

      return AlertDialog(
        title: const Text('My Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: myUsers.when(
            data: (List<ChatUser> users) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.image),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.id),
                    onTap: () async {
                      log("adding user to communtiy${user.id}");
                      await APIs.AdminAddUserToCommunity(commId, user.id, user,commName);
                      // Do something when a user is tapped
                    },
                  );
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    });
  }
}
