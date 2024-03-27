import 'dart:developer';
import 'package:com.while.while_app/view/profile/creator_profile_widget%20copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/resources/components/bottom_options_sheet.dart';
import 'package:com.while.while_app/view/profile/user_leaderboard_screen.dart';
import 'package:com.while.while_app/view/profile/creator_profile_widget.dart';
import 'package:com.while.while_app/view/profile/profile_data_widget2.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    log(user!.name);

    const tabBarIcons = [
      Tab(
        icon: Icon(
          Icons.photo_outlined,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.person,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.brush,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          user.name,
          style: GoogleFonts.ptSans(color: Colors.black),
        ),
        actions: [
          IconButton(
            iconSize: 35,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const MoreOptions();
                },
              );
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverList(
              delegate: SliverChildListDelegate(
                [const ProfileDataWidget()],
              ),
            ),
          ],
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Material(
                color: Colors.white,
                child: TabBar(
                  padding: EdgeInsets.all(0),
                  indicatorColor: Colors.black,
                  tabs: tabBarIcons,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(
                        child: CreatorProfile(
                      user: user,
                    )),
                    Center(
                        child: CreatorProfileVideo(
                      user: user,
                    )),
                    const Center(child: LeaderboardScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
