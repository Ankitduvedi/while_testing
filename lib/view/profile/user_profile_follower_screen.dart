import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/resources/components/message/apis.dart';
import 'package:com.while.while_app/resources/components/message/helper/dialogs.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileFollowerScreen extends ConsumerWidget {
  const UserProfileFollowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fireService = ref.read(apisProvider);
    final user = ref.watch(userProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Follower', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Follower', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .collection('follower')
              .snapshots(),
          builder: (context, followerSnapshot) {
            if (followerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!followerSnapshot.hasData) {
              return const Center(child: Text('No followers found.'));
            }
            final followerIds =
                followerSnapshot.data!.docs.map((doc) => doc.id).toList();
            return StreamBuilder<QuerySnapshot>(
              stream: fireService.getAllUsers(followerIds),
              builder: (context, usersSnapshot) {
                if (usersSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!usersSnapshot.hasData) {
                  return const Center(child: Text('No users found.'));
                }

                final users = usersSnapshot.data!.docs
                    .map((doc) =>
                        ChatUser.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No Connections Found!'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final person = users[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            50), // Adjust based on your layout needs
                        child: CachedNetworkImage(
                          imageUrl: person.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                      title: Text(person.name),
                      subtitle: Text(person.email),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          // await fireService.removeFollower(user.id, person.id); // Assuming you have this functionality
                          Dialogs.showSnackbar(context, 'Follower Removed');
                        },
                        child: const Text('Remove',
                            style: TextStyle(color: Colors.black)),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
