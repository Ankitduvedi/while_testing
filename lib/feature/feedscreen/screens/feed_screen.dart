import 'dart:developer';
import 'package:com.example.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.example.while_app/feature/feedscreen/screens/feed_screen_widget.dart';
import 'package:com.example.while_app/feature/notifications/screens/notification_view.dart';
import 'package:com.example.while_app/feature/feedscreen/controller/categories_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Future.microtask(
        () => ref.read(categoryProvider.notifier).fetchCategories(ref));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(categoryProvider.notifier).fetchCategories(ref);
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
    log("feedscreen");
    final unreadNotifsAsyncValue = ref.watch(listenUnreadNotifsProvider);
    final categoriesState = ref.watch(categoryProvider);
    // log(categoriesState.categories.toString());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('WHILE', style: GoogleFonts.ptSans(color: Colors.grey[800])),
        elevation: 0,
        backgroundColor: Colors.grey[200],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: unreadNotifsAsyncValue.when(
              data: (int unreadCount) {
                if (unreadCount == 0) {
                  return IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.black),
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()));
                    },
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.notifications_active_outlined,
                        color: Colors.blueAccent),
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()));
                    },
                  );
                }
              },
              error: (error, stack) =>
                  const Icon(Icons.error, color: Colors.red),
              loading: () => const Icon(Icons.notifications_none_rounded,
                  color: Colors.black),
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
