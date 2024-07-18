import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/social/controller/social_controller.dart';
import 'package:com.while.while_app/feature/social/screens/status/full_screen_status.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
//this iscomment

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
    final userId = ref.watch(userDataProvider).userData!.id; // Assuming this is how you get the user ID.

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
                  final followingDocs = followingSnapshot.docs.map((doc) => doc.id).toList();

                  // Filter out the people who are already followed by the user
                  final filteredPeople = peopleDocs.where((personDoc) {
                    final person = personDoc.data() as Map<String, dynamic>;
                    final personId = person['userId'];
                    return personId == userId || followingDocs.contains(personId);
                  }).toList();

                  return filteredPeople.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredPeople.length,
                          itemBuilder: (context, index) {
                            final person = filteredPeople[index].data() as Map<String, dynamic>;
                            final timestamp = person['timestamp'] as Timestamp;
                            final dateTime = timestamp.toDate();
                            final formattedDate = DateFormat.yMd().add_Hms().format(dateTime);

                            return Hero(
                              tag: 'status_${person['statusId']}',
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      context.push('/socials/statusScreen/fullStatusScreen/$index?', extra: filteredPeople.map((doc) => doc.data() as Map<String, dynamic>).toList());
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(mq!.height * .03),
                                      child: CachedNetworkImage(
                                        width: mq!.height * .055,
                                        height: mq!.height * .055,
                                        fit: BoxFit.fill,
                                        imageUrl: person['profileImg'],
                                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                      ),
                                    ),
                                    title: Text(person['userName'], style: GoogleFonts.ptSans(color: Colors.black)),
                                    subtitle: Text(formattedDate, style: GoogleFonts.ptSans(color: Colors.black)),
                                  ),
                                  Divider(color: Colors.grey.shade300, thickness: 1, height: 0),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No status found'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStatusInputDialog(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
    );
  }

  Future<void> _showStatusInputDialog(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _showImagePreviewDialog(imageFile, ref);
    }
  }

  void _showImagePreviewDialog(File imageFile, WidgetRef ref) {
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
                decoration: const InputDecoration(hintText: 'Enter your status'),
              ),
            ],
          ),
          actions: [
            TextButton(child: const Text('Cancel'), onPressed: () => context.pop()),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                // Assuming postStatus is a method in your API provider
                ref.read(apisProvider).postStatus(imageFile, _statusTextController.text);
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
