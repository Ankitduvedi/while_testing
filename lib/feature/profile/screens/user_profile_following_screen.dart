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
import 'package:go_router/go_router.dart';

class UserProfileFollowingScreen extends ConsumerStatefulWidget {
  const UserProfileFollowingScreen({super.key, required this.chatUser});
  final ChatUser chatUser;

  @override
  ConsumerState<UserProfileFollowingScreen> createState() =>
      UserProfileFollowingScreenState();
}

class UserProfileFollowingScreenState
    extends ConsumerState<UserProfileFollowingScreen> {
  List<ChatUser> _list = [];

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
        final screenSize = ref.read(sizeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>                             context.pop()

        ),
        title: const Text('Following', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: fireService.getFriendsUsersId(widget.chatUser),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
              // Handle the case where no data is available
              return const Center(
                  child: Text('No following found',
                      style: TextStyle(fontSize: 16)));
            }
            List<String> userIds =
                snapshot.data!.docs.map((doc) => doc.id).toList();
            if (userIds.isEmpty) {
              // Return or handle empty userIds case
              return const Center(
                  child: Text('No following found',
                      style: TextStyle(fontSize: 16)));
            }
            return StreamBuilder(
              stream: fireService.getAllUsers(userIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('No data available',
                          style: TextStyle(fontSize: 16)));
                }
                final data = snapshot.data?.docs;
                _list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
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
                                  builder: (_) => ProfileDialog(user: person));
                            },
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenSize.height * .03),
                              child: CachedNetworkImage(
                                width: screenSize.height * .055,
                                fit: BoxFit.fill,
                                height: screenSize.height * .055,
                                imageUrl: person.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),
                          ),
                          title: Text(
                            person.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            person.email,
                            style: const TextStyle(color: Colors.black38),
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
                                  Dialogs.showSnackbar(context, 'Unfollowed');
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
                      child: Text('You are not following anyone!',
                          style: TextStyle(fontSize: 20, color: Colors.black)));
                }
              },
            );
          },
        ),
      ),
    );
  }
}
