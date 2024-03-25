import 'package:com.example.while_app/feature/feedscreen/controller/categories_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.example.while_app/feature/feedscreen/screens/feed_video_screen.dart';

class FeedScreenWidget extends ConsumerStatefulWidget {
  const FeedScreenWidget({Key? key, required this.category}) : super(key: key);
  final String category;

  @override
  FeedScreenWidgetState createState() => FeedScreenWidgetState();
}

class FeedScreenWidgetState extends ConsumerState<FeedScreenWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref
        .read(allVideoProvider(widget.category).notifier)
        .fetchVideos(widget.category);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref
            .read(allVideoProvider(widget.category).notifier)
            .fetchVideos(widget.category);
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
    final state = ref.watch(allVideoProvider(widget.category));

    return SizedBox(
      height: 150,
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 3.0,
          childAspectRatio: 9 / 16,
        ),
        itemCount: state.videos.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.videos.length) {
            return const Center(child: CircularProgressIndicator());
          }

          String thumbnail = state.videos[index].thumbnail.isNotEmpty
              ? state.videos[index].thumbnail
              : 'path/to/default/thumbnail.jpg'; // Provide a default thumbnail path

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoScreen(video: state.videos[index]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white, // Base color
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-2, -2),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback for any error in loading the image
                          return Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey.shade400),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      state.videos[index].title,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
