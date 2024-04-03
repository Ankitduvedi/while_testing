import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/feature/profile/screens/friend_profile_screen%20copy.dart';
import 'package:com.while.while_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//home screen -- where all available contacts are shown
class UserProfileFollowerScreen extends ConsumerStatefulWidget {
  const UserProfileFollowerScreen({super.key, required this.chatUser});
  final ChatUser chatUser;

  @override
  ConsumerState<UserProfileFollowerScreen> createState() =>
      UserProfileFollowerScreenState();
}

class UserProfileFollowerScreenState
    extends ConsumerState<UserProfileFollowerScreen> {
  // for storing search status
  List<ChatUser> _list = [];

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Followers',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),

      //body
      body: SafeArea(
        child: StreamBuilder(
          // stream: APIs.getFriendsUsersId(widget.chatUser),
          stream: fireService.getFriendsFollowersUsersId(widget.chatUser),

          //get id of only known users
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              //if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

              //if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                return StreamBuilder(
                  stream: fireService.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                  //get only those user, who's ids are provided
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      // return const Center(
                      //     child: CircularProgressIndicator());

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              final person = _list[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => FriendProfileScreen(
                                                chatUser: person,
                                              )));
                                },
                                child: ListTile(
                                  leading: InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) =>
                                              ProfileDialog(user: person));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * .03),
                                      child: CachedNetworkImage(
                                        width: mq.height * .055,
                                        fit: BoxFit.fill,
                                        height: mq.height * .055,
                                        imageUrl: person.image,
                                        errorWidget: (context, url, error) =>
                                            const CircleAvatar(
                                                child: Icon(
                                                    CupertinoIcons.person)),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    person.name,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    person.email,
                                    style: const TextStyle(
                                        color:
                                            Colors.black38),
                                  ),
                                  trailing: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await fireService
                                          .unfollow(person.id)
                                          .then((value) {
                                        if (value) {
                                          Dialogs.showSnackbar(
                                              context, 'Unfollowed');
                                        }
                                      });
                                    },
                                    child: const Text(
                                      'Unfollow',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight
                                            .bold, // Adjust the font weight as needed
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text('You are not following Anyone!',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          );
                        }
                    }
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
