import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notifControllerProvider.notifier).markAllNotificationsRead();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(myNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: notificationsAsyncValue.when(
        data: (List<Map<String, dynamic>> notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No new notifications'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> notification = notifications[index];
              final String notificationText = notification['notificationText'];
              final Timestamp timestamp = notification['timeStamp'];
              final DateTime notificationTime = timestamp.toDate();
              final String timeAgo =
                  timeago.format(notificationTime, allowFromNow: true);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey[300]!,
                    //     offset: const Offset(4, 4),
                    //     blurRadius: 15,
                    //     spreadRadius: 1,
                    //   ),
                    //   const BoxShadow(
                    //     color: Colors.white,
                    //     offset: Offset(-4, -4),
                    //     blurRadius: 15,
                    //     spreadRadius: 1,
                    //   ),
                    // ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notificationText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
