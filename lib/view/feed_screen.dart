import 'dart:developer';
import 'package:com.example.while_app/view/feed_screen_widget.dart';
import 'package:com.example.while_app/view_model/providers/categories_test_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
              Text(categoriesState.categories[index]),
              FeedScreenWidget(category: categoriesState.categories[index]),
            ],
          );
        },
      ),
    );
  }
}
