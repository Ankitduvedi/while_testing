import 'dart:developer';

import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePagedemo extends ConsumerWidget {
  const MyHomePagedemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('Whole ui rebuild');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod"),
      ),
      body: Center(
        // Only this Consumer widget will rebuild when userDataProvider updates
        child: Consumer(
          builder: (context, ref, _) {
            final userProvider = ref.watch(userDataProvider);
            return Text(userProvider.userData!.about);
          },
        ),
      ),
    );
  }
}
