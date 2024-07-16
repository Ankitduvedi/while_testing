// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/SQlite_message_model.dart';
import 'package:com.while.while_app/main.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../chatfiledb.dart';
import '../../../../providers/apis.dart';
import '../../../../core/utils/my_date_util.dart';
import '../../../../data/model/chat_user.dart';
import '../../../../data/model/message.dart';
import '../../../../feature/social/screens/chat/message_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatUser user;
  final String myid;

  const ChatScreen({Key? key, required this.user, required this.myid})
      : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;
  bool _isUploading = false;
  List<MessageWithImage> messages = [];
  List<MessageWithImage> localMessages = [];
  List<MessageWithImage> realTimeMessages = [];
  bool isset = false;
  DatabaseHelper db = DatabaseHelper();
  Stream<QuerySnapshot<Map<String, dynamic>>>? messageStream;
  String conversationID = '';

  @override
  void initState() {
    super.initState();
    setmessagestream();
    final fireService = ref.read(apisProvider);
    conversationID = fireService.getConversationID(widget.user.id);
    FirebaseFirestore.instance
        .collection('users')
        .doc(ref.read(userDataProvider).userData!.id)
        .update({'isChattingWith': activeChatUserId});
  }

  void setmessagestream() async {
    await db.requestPermissions();

    String? lastTime = await db.getLastMessageTimestamp(conversationID);
    try {
      final lastVisible = await FirebaseFirestore.instance
          .collection('chats/$conversationID/messages')
          .doc(lastTime)
          .get();

      if (lastVisible.exists) {
        setState(() {
          messageStream = FirebaseFirestore.instance
              .collection('chats/$conversationID/messages')
              .orderBy('sent', descending: false)
              .startAfterDocument(lastVisible)
              .snapshots();
        });
      } else {
        setState(() {
          messageStream = FirebaseFirestore.instance
              .collection('chats/$conversationID/messages')
              .orderBy('sent', descending: true)
              .snapshots();
        });
      }

      _focusNode.addListener(() {
        if (!_focusNode.hasFocus) {
          setState(() {
            _showEmoji = false;
          });
        }
      });

      // Fetch local messages once
      localMessages = await db.getMessages(conversationID);
      // print('lengthlocal: ${localMessages.length}');
    } catch (e) {
      print('Error fetching last visible document: $e');
    }
  }

  @override
  void dispose() {
    log('dispose called');
    activeChatUserId = '';
    activechatid(ref, widget.myid);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void setEmoji() {
    setState(() {
      _showEmoji = !_showEmoji;
    });
  }

  void setUpload() {
    setState(() {
      _isUploading = !_isUploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _buildAppBar(context, fireService, widget.user),
          backgroundColor: Colors.white,
          toolbarHeight: 60,
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/chat_bg.png'),
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  _buildMessagesList(),
                  if (_isUploading) _buildUploadingIndicator(),
                  if (_showEmoji)
                    SizedBox(
                        height: mq.height * .35, child: _buildEmojiPicker()),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: MessageBox(
            _textController,
            _focusNode,
            widget.user,
            setEmoji,
            setUpload,
            messages.length,
            fireService.sendFirstMessage,
            fireService.sendMessage,
            fireService.sendChatImage,
          ),
        ),
      );
    });
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, streamSnapshot) {
        if (messageStream == null) {
          return SizedBox(
            height: mq.height * .78,
            child: ListView.builder(
              reverse: true,
              itemCount: localMessages.length,
              itemBuilder: (context, index) {
                return MessageCard(message: localMessages[index]);
              },
            ),
          );
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: mq.height * .78,
            child: ListView.builder(
              reverse: true,
              itemCount: localMessages.length,
              itemBuilder: (context, index) {
                return MessageCard(message: localMessages[index]);
              },
            ),
          );
        }

        if (streamSnapshot.hasError) {
          return Center(child: Text('Error: ${streamSnapshot.error}'));
        }

        if (!streamSnapshot.hasData) {
          return const Center(child: Text("No messages yet."));
        }

        List<Future<MessageWithImage>> messagesFutures =
            streamSnapshot.data!.docs.map((DocumentSnapshot document) async {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return await MessageWithImage.fromJson(data);
        }).toList();

        return FutureBuilder<List<MessageWithImage>>(
          future: Future.wait(messagesFutures),
          builder: (context, messagesSnapshot) {
            if (messagesSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: mq.height * .78,
                child: ListView.builder(
                  reverse: true,
                  itemCount: localMessages.length,
                  itemBuilder: (context, index) {
                    return MessageCard(message: localMessages[index]);
                  },
                ),
              );
            }

            if (messagesSnapshot.hasData) {
              realTimeMessages = messagesSnapshot.data!;
              for (var message in realTimeMessages) {
                db.insertMessage(conversationID, message);
              }

              messages =
                  [...localMessages, ...realTimeMessages].toSet().toList();
              print("len ${localMessages.length}");
              print("len1 ${realTimeMessages.length}");
              messages.sort((a, b) => b.sent.compareTo(a.sent));
            }

            return SizedBox(
              height: mq.height * .78,
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return MessageCard(message: messages[index]);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight * .35,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _textController.text += emoji.emoji;
          },
          config: const Config(
            columns: 7,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            recentsLimit: 28,
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, fireService, ChatUser user) {
    final fireServices = ref.read(apisProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          margin: const EdgeInsets.only(top: 40),
          child: Row(
            children: [
              //back button
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black)),

              //user profile picture
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(constraints.maxHeight * .03),
                child: CachedNetworkImage(
                  width: constraints.maxHeight * .05,
                  height: constraints.maxHeight * .05,
                  fit: BoxFit.fill,
                  imageUrl: user.image,
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
                  Text(user.name,
                      style: GoogleFonts.ptSans(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),

                  //last seen time of user
                  StreamBuilder(
                      stream: fireServices.getUserInfo(user.id),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Text(
                                user.isOnline == 1
                                    ? 'Online'
                                    : MyDateUtil.getLastActiveTime(
                                        context: context,
                                        lastActive: user.lastActive),
                                style: GoogleFonts.ptSans(
                                    fontSize: 13, color: Colors.black45));

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data;
                            return Text(
                                data!.isOnline == 1
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
    });
  }
}

class MessageBox extends ConsumerWidget {
  const MessageBox(
      this.textController,
      this.focusNode,
      this.user,
      this.setEmoji,
      this.setUpload,
      this.messageLength,
      this.sendFirstMessage,
      this.sendMessage,
      this.sendChatImage);

  final TextEditingController textController;
  final FocusNode focusNode;
  final ChatUser user;
  final VoidCallback setEmoji;
  final VoidCallback setUpload;
  final int messageLength;
  final void Function(ChatUser user, String message, Type type)
      sendFirstMessage;
  final void Function(ChatUser user, String message, Type type) sendMessage;
  final void Function(ChatUser user, File image) sendChatImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Changed from read to watch if using inside build for reactivity

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // This IconButton is wrapped with an Expanded widget with a small flex factor
            Expanded(
              flex: 1, // smaller flex factor means smaller space
              child: IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                    for (var i in images) {
                      log('Image Path: ${i.path}');
                      setUpload();
                      sendChatImage(user, File(i.path));
                      Future.delayed(const Duration(seconds: 1), () {
                        setUpload();
                      });
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 34)),
            ),
            // The main input field and buttons take up the remaining space
            Expanded(
              flex: 5, // larger flex factor means more space
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          setEmoji();
                        },
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.black, size: 28)),
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            if (messageLength != 0) {
                              sendMessage(user, textController.text, Type.text);
                            } else {
                              sendFirstMessage(
                                  user, textController.text, Type.text);
                            }
                            textController.clear();
                          }
                        }),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
