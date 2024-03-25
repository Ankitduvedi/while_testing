import 'dart:developer';

import 'package:com.example.while_app/view/reels_screen%20copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/feature/creator/screens/create_screen.dart';
import 'package:com.example.while_app/feature/feedscreen/screens/feed_screen.dart';
import 'package:com.example.while_app/view/profile/user_profile_screen2.dart';
import 'package:com.example.while_app/view/social/social_home_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    final fireSevice = ref.read(apisProvider);
    log("initState called");
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (fireSevice.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          fireSevice.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          fireSevice.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
    super.initState();
    _controller = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _controller,
        children: const [
          FeedScreen(),
          CreateScreen(),
          ReelsScreentest(),
          SocialScreen(),
          ProfileScreen()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(bottom: 2),
        color: Colors.white,
        height: 50,
        child: TabBar(
          controller: _controller,
          indicatorColor: Colors.transparent,
          onTap: (index) {
            setState(() {});
          },
          tabs: [
            Tab(
              icon: Icon(
                _controller.index == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 1
                    ? Icons.videocam_rounded
                    : Icons.videocam_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 2
                    ? Icons.slow_motion_video_rounded
                    : Icons.slow_motion_video_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 3
                    ? Icons.message_rounded
                    : Icons.message_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 4
                    ? Icons.account_circle_rounded
                    : Icons.account_circle_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
