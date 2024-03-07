import 'dart:developer';
import 'package:com.example.while_app/view/feed_screen_widget.dart';
import 'package:com.example.while_app/view/notifications/notification_view.dart';
import 'package:com.example.while_app/view_model/providers/categories_test_provider.dart';
import 'package:com.example.while_app/view_model/providers/notif_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  FeedScreenState createState() => FeedScreenState();
}


class FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  


  @override
  void initState() {
    super.initState();
     ref.read(notificationsProvider.notifier).fetchNotifications();

    // Initial fetch
    Future.microtask(
        () => ref.read(categoryProvider.notifier).fetchCategories());

    _scrollController.addListener(() {
      // Check if we're at the bottom of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Trigger loading more categories
        ref.read(categoryProvider.notifier).fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar:  AppBar(
        title: const Text('WHILE'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationsScreen()),
                );
                // Mark notifications as read when viewed
                ref.read(notificationsProvider.notifier).markNotificationsAsRead();
              },
              // Dynamically choose the icon
              child: Icon(notificationsState.hasNewNotifications ? Icons.notifications_active : Icons.notifications),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: categoriesState.categories.length +
            (categoriesState.isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          // Check if we're at the last item
          if (index >= categoriesState.categories.length) {
            // Show a loading indicator at the bottom
            return const Center(child: CircularProgressIndicator());
          }
          // Display category item
          log('list of categories length is ${categoriesState.categories.length}');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 7, 0),
                child: Text(
                  categoriesState.categories[index],
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              FeedScreenWidget(category: categoriesState.categories[index]),
            ],
          );
        },
      ),
    );
  }
}
