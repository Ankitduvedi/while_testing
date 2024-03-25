import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.example.while_app/view/social/full_screen_status.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusScreenState extends ConsumerStatefulWidget {
  const StatusScreenState({super.key});

  @override
  ConsumerState<StatusScreenState> createState() => _StatusScreenStateState();
}

class _StatusScreenStateState extends ConsumerState<StatusScreenState> {
  final TextEditingController _statusTextController = TextEditingController();

  List<String> friends = [];

  late String userId;

  late Stream<QuerySnapshot> peopleStream;

  int currentIndex = 0;

  Timer? statusTimer;
  @override
  void dispose() {
    _statusTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userId = ref.read(userProvider)!.id;
    peopleStream = FirebaseFirestore.instance
        .collection('statuses')
        .orderBy('userId')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    log('////');
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: peopleStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final peopleDocs = snapshot.data!.docs;
          // Fetch the list of people that the current user is following
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('my_users')
                .snapshots(),
            builder: (context, followingSnapshot) {
              if (followingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (followingSnapshot.hasError) {
                return Center(child: Text('Error: ${followingSnapshot.error}'));
              }

              final followingDocs =
                  followingSnapshot.data!.docs.map((doc) => doc.id).toList();

              // Filter out the people who are already followed by the user
              final filteredPeople = peopleDocs.where((personDoc) {
                final person = personDoc.data() as Map<String, dynamic>;
                final personId = person['userId'];
                return personId == userId || followingDocs.contains(personId);
              }).toList();
              log(filteredPeople.toString());
              return ListView.builder(
                itemCount: filteredPeople.length,
                itemBuilder: (context, index) {
                  List<QueryDocumentSnapshot<Object?>> querySnapshotList =
                      filteredPeople; // Your list of QueryDocumentSnapshots

                  List<Map<String, dynamic>> resultList =
                      querySnapshotList.map((snapshot) {
                    // Extract data from the QueryDocumentSnapshot
                    Map<String, dynamic> data =
                        snapshot.data() as Map<String, dynamic>;
                    return data;
                  }).toList();
                  final person =
                      filteredPeople[index].data() as Map<String, dynamic>;
                  final timestamp = person['timestamp'] as Timestamp;
                  final dateTime = timestamp
                      .toDate(); // Convert Firestore timestamp to DateTime
                  final formattedDate = DateFormat.yMd()
                      .add_Hms()
                      .format(dateTime); // Format the DateTime as a string

                  return Hero(
                    tag: 'status_${person['statusId']}',
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            // Navigate to the full status view screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullStatusScreen(
                                  statuses: resultList,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(mq.height * .03),
                            child: CachedNetworkImage(
                              width: mq.height * .055,
                              height: mq.height * .055,
                              fit: BoxFit.fill,
                              imageUrl: person['profileImg'],
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      child: Icon(CupertinoIcons.person)),
                            ),
                          ),
                          title: Text(
                            person['userName'],
                            style: GoogleFonts.ptSans(color: Colors.black),
                          ),
                          subtitle: Text(
                            formattedDate,
                            style: GoogleFonts.ptSans(color: Colors.black),
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                          height: 0,
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStatusInputDialog(context);
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _showStatusInputDialog(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Use ImageSource.camera for the camera

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Display the selected image in a dialog or store it for posting with status
      _showImagePreviewDialog(imageFile, ref);
    }
  }

  void _showImagePreviewDialog(File imageFile, WidgetRef ref) {
    showDialog<void>(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Preview'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(imageFile),
              TextField(
                controller: _statusTextController,
                decoration: const InputDecoration(
                  hintText: 'Enter your status',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                ref
                    .read(apisProvider)
                    .postStatus(imageFile, _statusTextController.text);
                // _postStatus(imageFile);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
