import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget%20copy.dart';
import 'package:com.while.while_app/feature/profile/screens/friend_profile_data_widget.dart';
import 'package:com.while.while_app/feature/profile/screens/user_leaderboard_screen.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendProfileScreen extends ConsumerWidget {
  const FriendProfileScreen({super.key, required this.chatUser});
  final ChatUser chatUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.read(userDataProvider).userData!;
    final followingUsersAsyncValue = ref.watch(followingUsersProvider(me.id));
    const tabBarIcons = [
      Tab(
        text: 'Loops',
      ),
      Tab(
        text: 'Videos',
      ),
      Tab(
        text: 'Dashboard',
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          backgroundColor: Colors.white,
          title: Text(
            chatUser.name,
            style: GoogleFonts.ptSans(color: Colors.black),
          ),
        ),
        body: followingUsersAsyncValue.when(
          data: (following) {
            final didFollow = following.contains(chatUser.id);
            return DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          FriendProfileDataWidget(
                            user: chatUser,
                            didFollow: didFollow,
                          )
                        ],
                      ),
                    ),
                  ];
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.white,
                      child: TabBar(
                          padding: const EdgeInsets.all(0),
                          //indicatorColor: const Color.fromARGB(255, 131, 85, 205),
                          labelColor: const Color.fromARGB(255, 196, 68, 216),
                          unselectedLabelColor: Colors.black,
                          labelStyle: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          unselectedLabelStyle: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          tabs: tabBarIcons,
                          indicator: CurvedGradientTabIndicator(
                              gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(230, 77, 255, 1),
                              Color.fromRGBO(123, 68, 212, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ))),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          didFollow
                              ? Center(
                                  child: CreatorProfile(
                                  user: chatUser,
                                ))
                              : Center(
                                  child: Text(
                                    'Private Account',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 20,
                                        height: 2,
                                        letterSpacing: 1,
                                        color: const Color.fromARGB(
                                            255, 81, 81, 81),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                          didFollow
                              ? Center(
                                  child: CreatorProfileVideo(
                                  user: chatUser,
                                ))
                              : Center(
                                  child: Text(
                                    'Private Account',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 20,
                                        height: 2,
                                        letterSpacing: 1,
                                        color: const Color.fromARGB(
                                            255, 81, 81, 81),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                          didFollow
                              ? const Center(child: LeaderboardScreen())
                              : Center(
                                  child: Text(
                                    'Private Account',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 20,
                                        height: 2,
                                        letterSpacing: 1,
                                        color: const Color.fromARGB(
                                            255, 81, 81, 81),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (e, _) => Center(child: Text('Error up: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
  }
}

class CurvedGradientTabIndicator extends Decoration {
  final BoxPainter _painter;

  CurvedGradientTabIndicator({required Gradient gradient})
      : _painter = _CurvedGradientPainter(gradient);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CurvedGradientPainter extends BoxPainter {
  final Gradient gradient;

  _CurvedGradientPainter(this.gradient);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          offset.dx,
          configuration.size!.height - 4, // Increased height
          configuration.size!.width * 1.4, // Reduced width
          12, // Increased height
        ),
      );
    final Rect rect = Offset(
          offset.dx + (configuration.size!.width * -.2), // Centered
          offset.dy + configuration.size!.height - 4, // Adjusted height
        ) &
        Size(configuration.size!.width * 1.4, 4); // Adjusted size
    final RRect rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, paint);
  }
}
