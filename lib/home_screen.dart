import 'dart:developer';
import 'package:com.while.while_app/feature/reels/screens/reels_screen.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/feature/creator/screens/create_screen.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_screen2.dart';
import 'package:com.while.while_app/feature/social/screens/social_home_screen.dart';

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
    ref.read(userDataProvider);
    return Scaffold(
      body: TabBarView(
        controller: _controller,
        children: const [
          FeedScreen(),
          CreateScreen(),
          ReelsScreen(),
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
                    ? FluentIcons.home_20_filled
                    : FluentIcons.home_20_regular,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 1
                    ? FluentIcons.video_add_20_filled
                    : FluentIcons.video_add_20_regular,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 2
                    ? FluentIcons.play_20_filled
                    : FluentIcons.play_20_regular,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 3
                    ? FluentIcons.chat_20_filled
                    : FluentIcons.chat_20_regular,
                size: 30,
                color: Colors.black,
              ),
            ),
            Tab(
              icon: Icon(
                _controller.index == 4
                    ? FluentIcons.person_20_filled
                    : FluentIcons.person_20_regular,
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
