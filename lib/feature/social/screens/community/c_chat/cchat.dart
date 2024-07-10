import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/social/controller/social_controller.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.while.while_app/data/model/community_message.dart';
import 'package:com.while.while_app/feature/social/screens/community/c_chat/community_message_card.dart';
 import '../../../../../main.dart';
import '../../../../../providers/apis.dart';
import '../../../../../data/model/community_user.dart';

// Convert to ConsumerStatefulWidget
class CChatScreen extends ConsumerStatefulWidget {
  final Community community;

  const CChatScreen({super.key, required this.community});

  @override
  ConsumerState<CChatScreen> createState() => _CChatScreenState();
}

// Extend from ConsumerState
class _CChatScreenState extends ConsumerState<CChatScreen> {
  List<CommunityMessage> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  final FocusNode _focusNode = FocusNode();
  late Stream<QuerySnapshot<Map<String, dynamic>>> messageStream;
  bool isset = false;
  @override
  void initState() {
     
    setmessagestream();
    super.initState();
  }

  void setEmoji() {
    setState(() {
      _showEmoji = !_showEmoji;
    });
  }

  void setUpload() {
    log("uploading val is $_isUploading");
    setState(() {
      _isUploading = !_isUploading;
    });
    log("uploading val is $_isUploading");
  }

  void uploadFile(List<XFile> images) {
    for (var i in images) {
      log('Image Path: ${i.path}');
      setState(() => _isUploading = true);
      ref
          .read(socialControllerProvider.notifier)
          .communitySendChatImage(widget.community, File(i.path), context);
      setState(() => _isUploading = false);
    }
  }

  Future<void> notifyCommunity(
      String communityId, String senderId, String message) async {
    List<String> memberTokens = await ref
        .read(apisProvider)
        .getCommunityMemberTokens(communityId, senderId);
    log('notifyCommunity $memberTokens');
    if (memberTokens.isNotEmpty) {
      await ref
          .read(apisProvider)
          .sendCommunityNotification(memberTokens, message, "Community Update");
    }
  }

  void setmessagestream() async {
     if (isset == false) {
      setState(() {
        messageStream = FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.community.id)
            .collection('chat')
            .orderBy('sent', descending: true)
            .snapshots();
        isset = true;
      });
    }
  }

  void sendMessage() {
     notifyCommunity(widget.community.id,
        ref.read(userDataProvider).userData!.id, _textController.text);

    ref.read(socialControllerProvider.notifier).sendCommunityMessage(
        widget.community.id, _textController.text, Types.text, context);
    // }
    _textController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    // MediaQueryData instance for responsive UI
    final screenSize = MediaQuery.of(context).size;
    setmessagestream();

    return GestureDetector(
      onTap: () {
        if (_showEmoji) {
          // Hide emojis if shown
          setState(() => _showEmoji = false);
        }
        //updated
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/comm_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              _buildMessagesList(),
              if (_isUploading) _buildUploadingIndicator(),
              MessageBox(_textController, _focusNode, setEmoji, setUpload,
                  sendMessage, uploadFile), // Pass 'screenSize' as an argument
              if (_showEmoji)
                SizedBox(
                  height: screenSize.height * .35, // Use 'screenSize' for responsive design
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

  Widget _buildUploadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Handle any errors that occur during fetching data
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              // Show a loading spinner while waiting for the data
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              // Once the data is available, convert your snapshots into a list of messages
              if (snapshot.hasData) {
                List<CommunityMessage> messages =
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  print("data $data");
                  return CommunityMessage.fromJson(data);
                }).toList();

                final data = snapshot.data!.docs;

                print("data  ${data.length}");
                // _list = data
                //     .map((doc) => CommunityMessage.fromJson(doc.data()))
                //     .toList();

                // Check if the list is empty
                if (messages.isEmpty) {
                  return const Center(
                    child:
                        Text('Say Hiiiii! 👋', style: TextStyle(fontSize: 20)),
                  );
                }

                // Return a ListView to display the messages
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      CommunityMessageCard(message: messages[index]),
                );
              } else {
                // Handle the case when there's no data
                return const Center(
                  child: Text('Start the conversation!'),
                );
              }
            default:
              // By default, show a loading spinner
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // bottom chat input field
  Widget _chatInput(BuildContext context, WidgetRef ref) {
            final screenSize = ref.read(sizeProvider);

    return Material(
      color: Colors.transparent,
      elevation: 25,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              screenSize.width * .005, screenSize.height * .01, screenSize.width * .005, 0

              //vertical: screenSize.height * 0, horizontal: screenSize.width * .01
              ),
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
                      ref
                          .read(socialControllerProvider.notifier)
                          .communitySendChatImage(
                              widget.community, File(i.path), context);
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 34)),

              //input field & buttons
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      //emoji button
                      IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showEmoji = !_showEmoji);
                          },
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              color: Colors.black, size: 28)),

                      Expanded(
                          child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.black),
                        maxLines: 1,
                        expands: false,
                        onTap: () {
                          if (_showEmoji) {
                            setState(() => _showEmoji = !_showEmoji);
                          }
                        },
                        decoration: const InputDecoration(
                            counterStyle: TextStyle(color: Colors.black),
                            fillColor: Colors.black,
                            hintText: 'Type Something...',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 108, 108, 108)),
                            border: InputBorder.none),
                      )),
                      SizedBox(width: screenSize.width * .02),
                    ],
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

                      ref
                          .read(socialControllerProvider.notifier)
                          .communitySendChatImage(
                              widget.community, File(image.path), context);
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.black, size: 32)),

              //send message button
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    Future<void> notifyCommunity(String communityId,
                        String senderId, String message) async {
                      List<String> memberTokens = await ref
                          .read(apisProvider)
                          .getCommunityMemberTokens(communityId, senderId);
                      log('notifyCommunity $memberTokens');
                      if (memberTokens.isNotEmpty) {
                        await ref.read(apisProvider).sendCommunityNotification(
                            memberTokens, message, "Community Update");
                      }
                    }

                    notifyCommunity(
                        widget.community.id,
                        ref.read(userDataProvider).userData!.id,
                        _textController.text);

                    ref
                        .read(socialControllerProvider.notifier)
                        .sendCommunityMessage(widget.community.id,
                            _textController.text, Types.text, context);
                    // }
                    _textController.text = '';
                  }
                },
                minWidth: 0,
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, right: 4, left: 8),
                shape: const CircleBorder(),
                color: Colors.black,
                child: const Icon(Icons.send, color: Colors.white, size: 25),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBox extends ConsumerWidget {
  const MessageBox(this.textController, this.focusNode, this.setEmoji,
      this.setUpload, this.sendMessage, this.sendChatImage);

  final TextEditingController textController;
  final FocusNode focusNode;

  final VoidCallback setEmoji;
  final VoidCallback setUpload;

  final void Function() sendMessage;
  final void Function(List<XFile> images) sendChatImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Changed from read to watch if using inside build for reactivity

    return Padding(
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
                  log("a1");

                  setUpload();
                  sendChatImage(images);
                  log("a2");
                  Future.delayed(const Duration(seconds: 2), () {
                    setUpload();
                    log("a4");
                  });

                  log("a3");
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
                          sendMessage();
                        }
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
