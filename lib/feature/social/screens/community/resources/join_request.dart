import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinRequestDialog extends ConsumerStatefulWidget {
  final String commId;
  final List<ChatUser> list;

  const JoinRequestDialog({Key? key, required this.commId, required this.list})
      : super(key: key);

  @override
  JoinRequestDialogState createState() => JoinRequestDialogState();
}

class JoinRequestDialogState extends ConsumerState<JoinRequestDialog> {
  @override
  Widget build(BuildContext context) {
    log("Building UserListDialog");
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    log(widget.list.length.toString());
    final communityParticipantsAsyncValue =
        ref.watch(communityUserRequestProvider(widget.commId));

    return Scaffold(
      appBar: AppBar(title: const Text('Approve Users')),
      body: allUsersAsyncValue.when(
        data: (allUsers) => communityParticipantsAsyncValue.when(
          data: (communityUsers) {
            final usersNotInCommunity = allUsers
                .where((user) => communityUsers.contains(user.id))
                .toList();
            log("Users not in the community: ${usersNotInCommunity.map((u) => u.name).join(', ')}");

            if (usersNotInCommunity.isEmpty) {
              return const Center(child: Text("No users available to add."));
            }

            return ListView.builder(
              itemCount: usersNotInCommunity.length,
              itemBuilder: (context, index) {
                final user = usersNotInCommunity[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    onPressed: () async {
                      log("Adding User: ${user.id} to community");
                      await ref
                          .watch(apisProvider)
                          .adminAddUserToCommunity(widget.commId, user);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .collection('my_communities')
                          .doc(widget.commId)
                          .set(
                              {'timeStamp': Timestamp.now(), 'approved': true});
                      await FirebaseFirestore.instance
                          .collection('communities')
                          .doc(widget.commId)
                          .collection('requests')
                          .doc(user.id)
                          .delete();

                      setState(() {}); // This forces the widget to rebuild
                    },
                    icon: const Icon(
                      Icons.add_task_rounded,
                      color: Colors.green,
                    ),
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
