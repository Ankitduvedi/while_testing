import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/counsellor/controller/counseller_contoller.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/feature/social/screens/chat/chat_screen.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounsellorDetailPage extends ConsumerStatefulWidget {
  final ChatUser userData;
  final Map<String, dynamic> extraData;

  const CounsellorDetailPage({
    Key? key,
    required this.userData,
    required this.extraData,
  }) : super(key: key);

  @override
  _CounsellorDetailPageState createState() => _CounsellorDetailPageState();
}

class _CounsellorDetailPageState extends ConsumerState<CounsellorDetailPage> {
  late Future<bool> isFollowing;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(userProvider);

    isFollowing = ref
        .read(counsellorContollerProvider.notifier)
        .checkIfUserDocumentExists(currentUser!.id, widget.userData.id);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(userProvider);
    final notifService = ref.read(notifControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Counsellor Details"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            CircleAvatar(
              radius: 100,
              backgroundImage:
                  CachedNetworkImageProvider(widget.userData.image),
            ),
            const SizedBox(height: 40),
            Text(widget.userData.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.extraData['organisation']),
            Text("Experience: ${widget.extraData['yearsOfExperience']} years"),
            Text("Customers Catered: ${widget.extraData['customersCatered']}"),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text("Call"),
                  onPressed: () {
                    // Implement calling functionality here
                  },
                ),
                if (currentUser!.id != widget.userData.id)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text("Chat"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(user: widget.userData),
                          ));
                    },
                  ),
                FutureBuilder<bool>(
                  future: isFollowing,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == false) {
                      return currentUser.id == widget.userData.id
                          ? ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_4_outlined),
                              label: const Text("You are a counseller"))
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.person_add),
                              label: const Text("Follow"),
                              onPressed: () async {
                                bool followed = await ref.read(
                                    followUserProvider)(widget.userData.id);
                                if (followed) {
                                  notifService.addNotification(
                                      "${currentUser.name} started following ${widget.userData.name}",
                                      widget.userData.id);
                                  setState(() {
                                    // Refresh the future to update the UI
                                    isFollowing = Future<bool>.value(true);
                                  });
                                }
                              },
                            );
                    } else {
                      return ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person),
                        label: const Text("Following"),
                      );
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
