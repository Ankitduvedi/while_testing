import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//home screen -- where all available contacts are shown
class FriendProfileFollowingScreen extends ConsumerStatefulWidget {
  const FriendProfileFollowingScreen({super.key, required this.chatUser, required this.userIds});
  final ChatUser chatUser;
  final List<String> userIds;

  @override
  ConsumerState<FriendProfileFollowingScreen> createState() => FriendProfileFollowingScreenState();
}

class FriendProfileFollowingScreenState extends ConsumerState<FriendProfileFollowingScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    final screenSize = ref.read(sizeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
                            context.pop();
          },
        ),
        title: const Text(
          'Following',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),

      //body
      body: StreamBuilder(
        stream: fireService.getFriendsUsersId(widget.chatUser),

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
                stream: fireService.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),

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
                      _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            final person = _list[index];
                            // widget.userIds.where(() => true);

                            return ListTile(
                              leading: InkWell(
                                onTap: () {
                                  showDialog(context: context, builder: (_) => ProfileDialog(user: person));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(screenSize.height * .03),
                                  child: CachedNetworkImage(
                                    width: screenSize.height * .055,
                                    fit: BoxFit.fill,
                                    height: screenSize.height * .055,
                                    imageUrl: person.image,
                                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                  ),
                                ),
                              ),
                              title: Text(person.name),
                              subtitle: Text(person.email),
                              trailing: ElevatedButton(
                                style: TextButton.styleFrom(elevation: 4, backgroundColor: Colors.white),
                                onPressed: () async {
                                  await fireService.addChatUser(person.email).then((value) {
                                    if (value) {
                                      Dialogs.showSnackbar(context, 'User Added');
                                    }
                                  });
                                },
                                child: Text(
                                  widget.userIds.contains(person.id) ? 'unfollow' : 'follow',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('No Connections Found!', style: TextStyle(fontSize: 20)),
                        );
                      }
                  }
                },
              );
          }
        },
      ),
    );
  }
}
