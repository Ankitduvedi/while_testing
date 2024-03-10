import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/streams/notif_stream.dart';
import 'package:com.example.while_app/theme/pallete.dart';
import 'package:com.example.while_app/view/feed_screen_widget.dart';
import 'package:com.example.while_app/view/notifications/notification_view.dart';
import 'package:com.example.while_app/view_model/providers/categories_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:google_fonts/google_fonts.dart';

// Ensure you have the right paths for your imports.

class FeedScreen extends river.ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  FeedScreenState createState() => FeedScreenState();
}

class FeedScreenState extends river.ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(categoryProvider.notifier).fetchCategories());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
    final String userId =
        APIs.me.id; // Adjust this to how you actually obtain the user ID
    // final isDarkTheme =
    //     ref.watch(themeNotifierProvider) == Pallete.darkModeAppTheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('WHILE', style: GoogleFonts.ptSans(color: Colors.grey[800])),
        elevation: 0,
        backgroundColor: Colors.grey[200],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: userId.isNotEmpty
                ? StreamBuilder<int>(
                    stream: listenToUnreadNotifications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Icon(Icons.error,
                            color: Colors.black); // Error state
                      }
                      if (!snapshot.hasData || snapshot.data == 0) {
                        // No unread notifications or loading state
                        return IconButton(
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: Colors.black),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen()),
                            );
                          },
                        );
                      }
                      // Unread notifications exist
                      return IconButton(
                        icon: const Icon(Icons.notifications_active_outlined,
                            color: Colors.redAccent),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen()),
                          );
                        },
                      );
                    },
                  )
                : const IconButton(
                    icon: Icon(Icons.notifications_none_rounded,
                        color: Colors.grey),
                    onPressed: null, // Disabled state
                  ),
          ),
          // Theme toggle button
          // IconButton(
          //   icon: Icon(
          //     isDarkTheme
          //         ? Icons.dark_mode_rounded
          //         : Icons.light_mode_rounded, // Adjust icons based on the theme
          //     color: Colors.black,
          //   ),
          //   onPressed: () =>
          //       ref.read(themeNotifierProvider.notifier).toggleTheme(),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: categoriesState.categories.length +
              (categoriesState.isLoading ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= categoriesState.categories.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildCategoryItem(categoriesState.categories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Lightened the base color for a cleaner look
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.shade300, // Lightened shadow for softer appearance
            offset:
                const Offset(2, 2), // Reduced shadow displacement for subtlety
            blurRadius: 6, // Reduced blur radius for a more refined shadow
            spreadRadius:
                1, // Adjusted spread radius to match the lighter shadow
          ),
          const BoxShadow(
            color:
                Colors.white, // Maintained a white shadow for the lifted effect
            offset: Offset(
                -2, -2), // Adjusted for consistency with the lighter theme
            blurRadius: 6, // Matching blur radius for the inner shadow
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.ptSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[
                  800], // Darkened text for better contrast on white background
            ),
          ),
          const SizedBox(height: 8),
          FeedScreenWidget(category: category),
        ],
      ),
    );
  }
}
