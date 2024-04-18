import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/apis.dart';
import 'chat_screen.dart';
import '../../../../core/utils/my_date_util.dart';

import '../../../../data/model/chat_user.dart';
import '../../../../data/model/message.dart';

import 'profile_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

//card to represent a single user in home screen
class ChatUserCard extends ConsumerStatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  ConsumerState<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends ConsumerState<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: () {
          // for navigating to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: fireService.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            // print(widget.localdata['image']);
            return ListTile(
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user),
                  );
                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height *
                      0.055, // setting radius for size
                  backgroundImage: NetworkImage(widget
                      .user.image), // using NetworkImage to load the image
                  onBackgroundImageError: (_, __) {
                    // Handling errors in image loading
                    // Log error or handle the image load failure appropriately
                    log('Failed to load image');
                  },
                  // Default image to show in case of an error or while the image is loading
                  backgroundColor: Colors.grey[
                      200], // optional: background color, shows while image is loading
                  child: Text(
                      widget.user.name[0]
                          .toUpperCase(), // Show the first letter of the user's name as fallback
                      style: const TextStyle(
                          color: Colors.white)), // Styling for text
                ),
              ),
              title: Text(
                widget.user.name,
                style: GoogleFonts.ptSans(color: Colors.black),
              ),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
                style: GoogleFonts.ptSans(color: Colors.black54),
              ),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty &&
                          _message!.fromId != fireService.user.uid
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent,
                          ),
                          style: GoogleFonts.ptSans(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }
}
