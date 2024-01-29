import 'package:com.example.while_app/view/profile/demo.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view/create_screen.dart';
import 'package:com.example.while_app/view/feed_screen.dart';
import 'package:com.example.while_app/view/profile/user_profile_screen.dart';
import 'package:com.example.while_app/view/reels_screen.dart';
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
    // listUsersFollowers();
    //final userDataProvider = Provider.of<UserDataProvider>(context);
    //ref.watch(userDataProvider);
    APIs.getSelfInfo();
    super.initState();
    _controller = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    //final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      body: TabBarView(
        controller: _controller,
        children: [
          MyHomePagedemo(),
          CreateScreen(),
          ReelsScreen(),
          SocialScreen(),
          ProfileScreen()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.only(bottom: 2),
          color: Colors.black,
          height: 50,
          // shape: const CircularNotchedRectangle(),
          //color: currentTheme.primaryColor,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: _controller,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.home,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.videocam_outlined,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.slow_motion_video_outlined,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.message_outlined,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                ),
              ),
            ],
          )),
    );
  }
}
