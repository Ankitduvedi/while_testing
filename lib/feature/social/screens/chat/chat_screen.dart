// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.while.while_app/feature/social/screens/chat/message_card.dart';
import '../../../../main.dart';
import '../../../../providers/apis.dart';
import '../../../../core/utils/my_date_util.dart';
import '../../../../data/model/chat_user.dart';
import '../../../../data/model/message.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_showEmoji) {
          // Hide emojis if shown
          setState(() => _showEmoji = false);
        }
      },
      child: Scaffold(
        //app bar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(fireService),
          backgroundColor: Colors.white,
          toolbarHeight: 60,
        ),

        backgroundColor: Colors.white,

        //body
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/chat_bg.png'), fit: BoxFit.cover)),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: fireService.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              });
                        } else {
                          return Center(
                            child: Text('Say Hii! 👋',
                                style: GoogleFonts.ptSans(fontSize: 20)),
                          );
                        }
                    }
                  },
                ),
              ),

              //progress indicator for showing uploading
              if (_isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2))),

              //chat input filed
              _chatInput(fireService),

              //show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 234, 248, 255),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar(fireservice) {
    final fireServices = ref.read(apisProvider);

    return Container(
        margin: const EdgeInsets.only(top: 40),
        child: Row(
          children: [
            //back button
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.blue.shade300)),

            //user profile picture
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                width: mq.height * .05,
                height: mq.height * .05,
                fit: BoxFit.fill,
                imageUrl: widget.user.image,
                errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(
                  CupertinoIcons.person,
                  color: Colors.white,
                )),
              ),
            ),

            //for adding some space
            const SizedBox(width: 10),

            //user name & last seen time
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user name
                Text(widget.user.name,
                    style: GoogleFonts.ptSans(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),

                //last seen time of user
                StreamBuilder(
                    stream: fireServices.getUserInfo(widget.user.id),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Text(
                              widget.user.isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: widget.user.lastActive),
                              style: GoogleFonts.ptSans(
                                  fontSize: 13, color: Colors.black45));

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data;
                          return Text(
                              data!.isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: data.lastActive),
                              style: GoogleFonts.ptSans(
                                  fontSize: 13, color: Colors.black45));
                      }
                    })
              ],
            )
          ],
        ));
  }

  // bottom chat input field
  Widget _chatInput(fireservice) {
    return Material(
      elevation: 25,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: mq.height * .01, horizontal: mq.width * .01),
          child: Row(
            children: [
              //pick image from gallery button
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    // Picking multiple images
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);

                    // uploading & sending image one by one
                    for (var i in images) {
                      log('Image Path: ${i.path}');
                      setState(() => _isUploading = true);
                      await fireservice.sendChatImage(
                          widget.user, File(i.path));
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.add,
                      color: Colors.lightBlueAccent, size: 34)),
              //input field & buttons
              Expanded(
                child: SizedBox(
                  child: Card(
                    //shadowColor: Colors.blue,
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: GoogleFonts.ptSans(),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onTap: () {
                              if (_showEmoji) {
                                setState(() => _showEmoji = !_showEmoji);
                              }
                            },
                            decoration: InputDecoration(
                                //hintText: 'Type Something...',
                                hintStyle:
                                    GoogleFonts.ptSans(color: Colors.black),
                                border: InputBorder.none),
                          ),
                        ),

                        //emoji button
                        IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _showEmoji = !_showEmoji);
                            },
                            icon: const Icon(Icons.emoji_emotions_outlined,
                                color: Colors.lightBlueAccent, size: 28)),

                        //adding some space
                        //SizedBox(width: mq.width * .005,),
                      ],
                    ),
                  ),
                ),
              ),
              //take image from camera button
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    // Pick an image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() => _isUploading = true);

                      await fireservice.sendChatImage(
                          widget.user, File(image.path));
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.lightBlueAccent, size: 32)),

              //send message button
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    if (_list.isEmpty) {
                      //on first message (add user to my_user collection of chat user)
                      fireservice.sendFirstMessage(
                          widget.user, _textController.text, Type.text);
                    } else {
                      //simply send message
                      fireservice.sendMessage(
                          widget.user, _textController.text, Type.text);
                    }
                    _textController.text = '';
                  }
                },
                minWidth: 0,
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, right: 4, left: 8),
                shape: const CircleBorder(),
                color: Colors.lightBlueAccent,
                child: const Icon(Icons.send, color: Colors.white, size: 25),
              )
            ],
          ),
        ),
      ),
    );
  }
}
