
import 'package:com.while.while_app/feature/profile/screens/friend_profile_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.arrow_back, color: Colors.black,)),
        backgroundColor: Colors.white,
        title: Text(
          chatUser.name,
          style: GoogleFonts.ptSans(color: Colors.black),
        ),
        
      ),
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
                      user: chatUser,
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
