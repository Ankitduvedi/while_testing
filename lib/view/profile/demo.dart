import 'dart:developer';

import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<ChatUser>> usersAsyncValue =
        ref.watch(usersDataStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Users List')),
      body: usersAsyncValue.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(title: Text(user.name));
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
