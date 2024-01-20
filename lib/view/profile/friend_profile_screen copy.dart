import 'package:flutter/material.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view/profile/creator_profile_widget.dart';
import 'package:com.example.while_app/view/profile/friend_profile_data_widget.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key, required this.chatUser});
  final ChatUser chatUser;

  @override
  Widget build(BuildContext context) {
    const tabBarIcons = [
      Tab(
        icon: Icon(
          Icons.photo_outlined,
          color: Colors.black,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.person,
          color: Colors.black,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.brush,
          color: Colors.black,
          size: 30,
        ),
      ),
    ];

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FriendProfileDataWidget(
                      chatUser: chatUser,
                    )
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              const Material(
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
                      userID: chatUser.id,
                    )),
                    const Center(child: Text("Become a Mentor")),
                    const Center(child: Text("Become a Freelancer")),
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
