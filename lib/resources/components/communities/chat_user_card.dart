import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:while_app/main.dart';

import '../message/apis.dart';
import '../message/chat_screen.dart';
import '../message/helper/my_date_util.dart';

import '../message/models/chat_user.dart';
import '../message/models/message.dart';

import '../message/widgets/dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final localdata;
  final int locindex;
  const ChatUserCard(
      {super.key,
      required this.user,
      required this.localdata,
      required this.locindex});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    // _initImage();
  }

  // _initImage() async {
  //   bytes = await getIMG();
  //   setState(() {}); // Trigger a rebuild after obtaining the image bytes
  // }

  // Future<Uint8List?> getIMG() async {
  //   try {
  //     return await base64Decode(widget.localdata['image']);
  //   } catch (error) {
  //     print("Error decoding image: $error");
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0),
      color: Colors.black,
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
          stream: APIs.getLastMessage(widget.user),
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
                  // child: bytes != null
                  //     ? Image.memory(
                  //         bytes!,
                  //         width: mq.height * .055,
                  //         fit: BoxFit.fill,
                  //         height: mq.height * .055,
                  //       )
                  //     : const CircleAvatar(
                  //         child: Icon(CupertinoIcons.person),
                  //       ),
                ),
              ),
              title: Text(
                widget.user.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
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
                          style: const TextStyle(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }
}
