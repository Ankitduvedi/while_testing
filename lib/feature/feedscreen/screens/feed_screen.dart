import 'dart:developer';
import 'package:com.example.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.example.while_app/feature/feedscreen/screens/feed_screen_widget.dart';
import 'package:com.example.while_app/feature/notifications/screens/notification_view.dart';
import 'package:com.example.while_app/feature/feedscreen/controller/categories_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true, // makes the app bar hide and show on scroll
              snap: true, // snap effects
              automaticallyImplyLeading: false,
              title: Image.asset('assets/while_transparent.png',
                  width: 110 // Dynamic width for the image
                  ),
              elevation: 0,
              backgroundColor: Colors.white,
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
                                builder: (context) =>
                                    const NotificationsScreen()));
                          },
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.notifications_active_outlined,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen()));
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // Check if we're at the last item
                  if (index >= categoriesState.categories.length) {
                    // Show a loading indicator at the bottom
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Display category item
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(11, 7, 7, 0),
                        child: Text(
                          categoriesState.categories[index],
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      FeedScreenWidget(
                          category: categoriesState.categories[index]),
                    ],
                  );
                },
                childCount: categoriesState.categories.length +
                    (categoriesState.isLoading ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
