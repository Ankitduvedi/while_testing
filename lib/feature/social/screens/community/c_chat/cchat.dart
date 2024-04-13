import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/social/controller/social_controller.dart';
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
  late Community community;
  @override
  void initState() {
    super.initState();
    community = widget.community;
  }

  List<CommunityMessage> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    // MediaQueryData instance for responsive UI
    final mq = MediaQuery.of(context).size;

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
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream:
                      ref.read(apisProvider).getAllCommunityMessages(community),
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
                          final data = snapshot.data!.docs;
                          _list = data
                              .map((doc) =>
                                  CommunityMessage.fromJson(doc.data()))
                              .toList();

                          // Check if the list is empty
                          if (_list.isEmpty) {
                            return const Center(
                              child: Text('Say Hi! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }

                          // Return a ListView to display the messages
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            itemBuilder: (context, index) =>
                                CommunityMessageCard(message: _list[index]),
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
              ),

              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _chatInput(context, ref), // Pass 'mq' as an argument
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35, // Use 'mq' for responsive design
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

  // bottom chat input field
  Widget _chatInput(BuildContext context, WidgetRef ref) {
    return Material(
      //elevation: 25,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              mq.width * .005, mq.height * .01, mq.width * .005, 0

              //vertical: mq.height * 0, horizontal: mq.width * .01
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
                              community, File(i.path), context);
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.add,
                      color: Colors.lightBlueAccent, size: 34)),

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
                              color: Colors.lightBlueAccent, size: 28)),

                      Expanded(
                          child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.black),
                        maxLines: null,
                        onTap: () {
                          if (_showEmoji) {
                            setState(() => _showEmoji = !_showEmoji);
                          }
                        },
                        decoration: const InputDecoration(
                            counterStyle: TextStyle(color: Colors.black),
                            fillColor: Colors.black,
                            hintText: 'Type Something...',
                            hintStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none),
                      )),
                      SizedBox(width: mq.width * .02),
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
                              community, File(image.path), context);
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.lightBlueAccent, size: 32)),

              //send message button
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    ref
                        .read(socialControllerProvider.notifier)
                        .sendCommunityMessage(community.id,
                            _textController.text, Types.text, context);
                    // }
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
