import 'package:com.example.while_app/view_model/providers/user_notif_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notificationsAsyncValue.when(
        data: (List<String> notifications) {
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notifications[index]),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
