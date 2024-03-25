import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.example.while_app/main.dart';
import '../message/apis.dart';
import 'cdetail.dart';
import '../message/helper/my_date_util.dart';
import '../../../data/model/community_message.dart';
import '../../../data/model/community_user.dart';
import 'community_profile_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

//card to represent a single user in home screen
class ChatCommunityCard extends ConsumerStatefulWidget {
  final Community user;

  const ChatCommunityCard({super.key, required this.user});

  @override
  ConsumerState<ChatCommunityCard> createState() => _ChatCommunityCardState();
}

class _ChatCommunityCardState extends ConsumerState<ChatCommunityCard> {
  //last message info (if null --> no message)
  CommunityMessage? _message;

  @override
  Widget build(BuildContext context) {
    log(widget.user.name);
    final fireService = ref.read(apisProvider);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0),
      color: Colors.white,
      //elevation: 5,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            // for navigating to chat screen

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CCommunityDetailScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: fireService
          .getLastCommunityMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data
                      ?.map((e) => CommunityMessage.fromJson(e.data()))
                      .toList() ??
                  [];
              if (list.isNotEmpty) {
                _message = list[0];
                log('message ${_message!.msg}');
              }

              return ListTile(
                //user profile picture
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) =>
                            CommunityProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                //user name
                title: Text(
                  widget.user.name,
                  style: GoogleFonts.ptSans(color: Colors.black),
                ),

                //last message
                subtitle: Text(
                  _message != null
                      ? _message!.types == Types.image
                          ? 'image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                  style: GoogleFonts.ptSans(color: Colors.black54),
                ),

                //last message time
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromId !=  fireService.user.uid
                        ?
                        //show for unread message
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        :
                        //message sent time
                        Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: GoogleFonts.ptSans(color: Colors.black87),
                          ),
              );
            },
          )),
    );
  }
}
