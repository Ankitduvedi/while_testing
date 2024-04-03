import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/social/controller/social_controller.dart';
import 'package:com.while.while_app/feature/social/screens/status/full_screen_status.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StatusScreenState extends ConsumerStatefulWidget {
  const StatusScreenState({Key? key}) : super(key: key);

  @override
  ConsumerState<StatusScreenState> createState() => _StatusScreenStateState();
}

class _StatusScreenStateState extends ConsumerState<StatusScreenState> {
  final TextEditingController _statusTextController = TextEditingController();
  Size? mq;

  @override
  void dispose() {
    _statusTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    final userId = ref.watch(userProvider)!.id;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer(
        builder: (context, ref, _) {
          final peopleStream = ref.watch(peopleStreamProvider);
          final followingStream = ref.watch(followingStreamProvider(userId));
          return peopleStream.when(
            data: (peopleSnapshot) {
              final peopleDocs = peopleSnapshot.docs;
              return followingStream.when(
                data: (followingSnapshot) {
                  final followingDocs =
                      followingSnapshot.docs.map((doc) => doc.id).toList();

                  // Filter out the people who are already followed by the user
                  final filteredPeople = peopleDocs.where((personDoc) {
                    final person = personDoc.data() as Map<String, dynamic>;
                    final personId = person['userId'];
                    return personId == userId ||
                        followingDocs.contains(personId);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredPeople.length,
                    itemBuilder: (context, index) {
                      final person =
                          filteredPeople[index].data() as Map<String, dynamic>;
                      final timestamp = person['timestamp'] as Timestamp?;
                      final dateTime = timestamp?.toDate() ?? DateTime.now();
                      final formattedDate =
                          DateFormat.yMd().add_Hms().format(dateTime);

                      return Hero(
                        tag: 'status_${person['statusId']}',
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullStatusScreen(
                                        statuses: filteredPeople
                                            .map((doc) => doc.data()
                                                as Map<String, dynamic>)
                                            .toList(),
                                        initialIndex: index,
                                      ),
                                    ));
                              },
                              leading: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq!.height * .03),
                                child: CachedNetworkImage(
                                  width: mq!.height * .055,
                                  height: mq!.height * .055,
                                  fit: BoxFit.fill,
                                  imageUrl: person['profileImg'],
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                              title: Text(person['userName'],
                                  style:
                                      GoogleFonts.ptSans(color: Colors.black)),
                              subtitle: Text(formattedDate,
                                  style:
                                      GoogleFonts.ptSans(color: Colors.black)),
                            ),
                            Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 0),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Error: $error'),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          );
        },
      ),
      floatingActionButton: Consumer(builder: (context, ref, child) {
        final SocialController statusService =
            ref.read(socialControllerProvider.notifier);
        bool loading = ref.watch(socialControllerProvider);

        return FloatingActionButton(
            onPressed: () =>
                _showStatusInputDialog(context, statusService),
            backgroundColor: Colors.white,
            child: loading
                ? const CircularProgressIndicator()
                : const Icon(Icons.add_rounded, color: Colors.black));
      }),
    );
  }
  //commnet

  Future<void> _showStatusInputDialog(BuildContext context,
      SocialController statusService) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      _showImagePreviewDialog(imageFile, statusService);
    }
  }

  void _showImagePreviewDialog(File imageFile, SocialController statusService) {

     showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Image Preview'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(imageFile),
                    TextField(
                      controller: _statusTextController,
                      decoration:
                          const InputDecoration(hintText: 'Enter your status'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  
                    TextButton(
                          child: const Text('Post'),
                          onPressed: () {
                            // Assuming postStatus is a method in your API provider

                            statusService.postStatus(
                                imageFile, _statusTextController.text, context);
                          },
                        ),
                ],
              );
            });
  }
}
