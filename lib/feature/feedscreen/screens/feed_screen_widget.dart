import 'package:com.while.while_app/feature/feedscreen/controller/categories_test_provider.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_video_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Initial fetch
    Future.microtask(() => ref
        .read(allVideoProvider(widget.category).notifier)
        .fetchVideos(widget.category));

    _scrollController.addListener(() {
      // Check if we're at the bottom of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Trigger loading more categories
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
    log('Total numbers of videos ${state.videos.length} category${widget.category}');
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: SizedBox(
        height: 300,
        child: GridView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 13.0,
            childAspectRatio: 12 / 11,
          ),
          itemCount: state.videos.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.videos.length) {
              // Show a loading indicator at the bottom
              return const Center(child: CircularProgressIndicator());
            }
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoScreen(video: state.videos[index]),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(state.videos[index].thumbnail),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            state.videos[index].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 10),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: [
                        //       const Icon(
                        //         Icons.timer,
                        //         size: 18,
                        //         color: Color.fromARGB(255, 188, 188, 188),
                        //       ),
                        //       Text(
                        //         '1h 21m',
                        //         maxLines: 1,
                        //         style: GoogleFonts.spaceGrotesk(
                        //             color: const Color.fromARGB(
                        //                 255, 188, 188, 188),
                        //             fontSize: 12,
                        //             fontWeight: FontWeight.w700),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const Row(
                        //   children: [
                        //     Padding(
                        //       padding: EdgeInsets.all(8.0),
                        //       child: OutlinedText(
                        //         text: 'Flutter',
                        //         fillColor: Color.fromARGB(255, 77, 201, 209),
                        //         textColor: Colors.white,
                        //         borderColor: Colors.blue,
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: EdgeInsets.all(8.0),
                        //       child: OutlinedText(
                        //         text: 'Dart',
                        //         fillColor: Color.fromARGB(255, 0, 130, 205),
                        //         textColor: Colors.white,
                        //         borderColor: Colors.blue,
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: EdgeInsets.all(8.0),
                        //       child: OutlinedText(
                        //         text: 'Development',
                        //         fillColor: Color.fromARGB(255, 141, 94, 242),
                        //         textColor: Colors.white,
                        //         borderColor: Colors.blue,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'by. ${state.videos[index].creatorName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OutlinedText extends StatelessWidget {
  final String text;
  final Color fillColor;
  final Color textColor;
  final Color borderColor;

  const OutlinedText({
    Key? key,
    required this.text,
    required this.fillColor,
    required this.textColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fillColor,
        //border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
            color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
