import 'dart:developer';

import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyConsumerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ChatUser> userAsyncValue =
        ref.watch(connectUserDataStreamProvider(APIs.me.id));

    return Scaffold(
      appBar: AppBar(title: Text('User Data')),
      body: Center(
        child: userAsyncValue.when(
          data: (chatUser) => Text('User Name: ${chatUser.name}'),
          loading: () => CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
