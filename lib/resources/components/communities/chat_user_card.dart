import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../message/apis.dart';
import '../message/chat_screen.dart';
import '../message/helper/my_date_util.dart';

import '../../../data/model/chat_user.dart';
import '../../../data/model/message.dart';

import '../message/widgets/dialogs/profile_dialog.dart';
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    height: mq.height * .055,
                    width: mq.height * .055,
                  ),
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
                  : _message!.read.isEmpty && _message!.fromId != fireService.user.uid
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
