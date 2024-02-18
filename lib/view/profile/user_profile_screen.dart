import 'package:com.example.while_app/view/profile/user_leaderboard_screen.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/view/profile/creator_profile_widget.dart';
import 'package:com.example.while_app/view/profile/profile_data_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [ProfileDataWidget()],
                  ),
                ),
              ];
            },
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
                      Consumer(builder: (context, ref, child) {
                        final user = ref.watch(userDataProvider).userData;
                        return Center(
                            child: CreatorProfile(
                          userID: user!.id,
                        ));
                      }),
                      const Center(child: LeaderboardScreen()),
                      const Center(
                          child: Text(
                        "Become a Freelancer",
                        style: TextStyle(color: Colors.black),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
