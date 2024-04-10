import 'dart:developer';
import 'dart:io';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class AddCommunityScreen {
  XFile? image;

  void addCommunityDialog(BuildContext context, WidgetRef ref) {
    String name = '';
    String type = '';
    String domain = '';
    String about = '';

    showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside of it
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        scrollable: true,
        elevation: 5, // Increased elevation for a more pronounced shadow
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 24), // Adjusted for a bit more space
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)), // Rounded corners
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blueAccent, size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                'Create Community',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue), // Changed color to match the theme
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onChanged: (value) => name = value,
              decoration: InputDecoration(
                  hintText: 'Name',
                  prefixIcon: const Icon(Icons.group,
                      color: Colors
                          .blueAccent), // Icon changed to group and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => about = value,
              decoration: InputDecoration(
                  hintText: 'About',
                  prefixIcon: const Icon(Icons.info_outline,
                      color: Colors
                          .blueAccent), // Icon changed for semantic purposes and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => domain = value,
              decoration: InputDecoration(
                  hintText: 'Domain',
                  prefixIcon: const Icon(Icons.domain,
                      color: Colors
                          .blueAccent), // Icon changed to domain and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => type = value,
              decoration: InputDecoration(
                  hintText: 'Primary/Secondary',
                  prefixIcon: const Icon(Icons.swap_horiz,
                      color: Colors
                          .blueAccent), // Icon changed for semantic purposes and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildButton(context, 'Camera', Icons.camera_alt_rounded,
                  ImageSource.camera),
              _buildButton(
                  context, 'Gallery', Icons.photo, ImageSource.gallery),
            ]),
          ],
        ),
        actions: [
          // Actions layout adjusted to ensure buttons are on the same line
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 244, 182, 182),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 4,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Discard',
                  style: TextStyle(color: Colors.black, fontSize: 16))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 174, 239, 133),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 4,
              ),
              onPressed: () async {
                // Your create logic here
                if (type != '' && name != '') {
                  final time = DateTime.now().millisecondsSinceEpoch.toString();
                  final String id = uuid.v4();

                  final Community community = Community(
                      image: '',
                      about: about,
                      name: name,
                      createdAt: time,
                      id: id,
                      email: ref.read(userProvider)!.email,
                      type: type,
                      noOfUsers: '1',
                      domain: domain,
                      timeStamp: time,
                      easyQuestions: 0,
                      hardQuestions: 0,
                      mediumQuestions: 0,
                      admin: ref.read(userProvider)!.name);
                  log("creating");
                  ref
                      .read(apisProvider)
                      .addCommunities(community, File(image!.path));
                  // APIs.addCommunities(community, File(image!.path));
                  log("created");
                  Navigator.pop(context);
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: Colors.black, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, IconData icon, ImageSource source) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Colors.blueGrey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      icon: Icon(icon, color: Colors.blueAccent, size: 24),
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        image = await picker.pickImage(source: source, imageQuality: 70);
      },
    );
  }
}
