import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';

import '../../../../../main.dart';
import '../../../../../providers/apis.dart';
import '../../../../../core/utils/dialogs/dialogs.dart';
import '../../../../../core/utils/my_date_util.dart';
import '../../../../../data/model/community_message.dart';

// for showing single message details
class CommunityMessageCard extends ConsumerStatefulWidget {
  const CommunityMessageCard({super.key, required this.message});

  final CommunityMessage message;

  @override
  ConsumerState<CommunityMessageCard> createState() =>
      _CommunityMessageCardState();
}

class _CommunityMessageCardState extends ConsumerState<CommunityMessageCard> {
  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    bool isMe = fireService.user.uid == widget.message.fromId;

    return widget.message.types == Types.joined
        ? Center(
            child: Text(
            widget.message.msg,
            style: const TextStyle(color: Color.fromARGB(255, 26, 144, 199)),
          ))
        : InkWell(
            onLongPress: () {
              _showBottomSheet(isMe);
            },
            child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    // if (widget.message.read.isEmpty) {
    //   APIs.updateMessageReadStatus(widget.message);
    // }
            final screenSize = ref.read(sizeProvider);


    return Column(
      children: [
        //message content
        Row(
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.types == Types.image
                    ? screenSize.width * .03
                    : screenSize.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * .04, vertical: screenSize.height * .01),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade800),
                    //making borders curved
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: widget.message.types == Types.text
                    ?
                    //show text

                    Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        textAlign: TextAlign.start,
                      )
                    :
                    //show image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: screenSize.width * 0.7,
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
                '${widget.message.senderName} : ${MyDateUtil.getFormattedTime(context: context, time: widget.message.sent)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
            final screenSize = ref.read(sizeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            // SizedBox(width: screenSize.width * .04),

            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            // Text('Seen'),

            //for adding some space
            const SizedBox(width: 2),

            //sent time
            // Text(
            //   MyDateUtil.getFormattedTime(
            //       context: context, time: widget.message.sent),
            //   style: const TextStyle(fontSize: 13, color: Colors.black54),
            // ),
          ],
        ),

        //message content
        Flexible(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(widget.message.types == Types.image
                    ? screenSize.width * .03
                    : screenSize.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * .04, vertical: screenSize.height * .01),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade800),
                    //making borders curved
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30))),
                child: widget.message.types == Types.text
                    ?
                    //show text
                    Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    :
                    //show image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: screenSize.width * 0.7,
                          fit: BoxFit.contain,
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 0,
                              color: Colors.lightGreen,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              )
            ],
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
            final screenSize = ref.read(sizeProvider);

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: screenSize.height * .015, horizontal: screenSize.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.types == Types.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                            context.pop();

                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image Url: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'We Chat')
                              .then((success) {
                            //for hiding bottom sheet
                            context.pop();
                            if (success != null && success) {
                              Dialogs.showSnackbar(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: screenSize.width * .04,
                  indent: screenSize.width * .04,
                ),

              //edit option
              if (widget.message.types == Types.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                            context.pop();

                      _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      // await APIs.deleteMessage(widget.message).then((value) {
                      //   //for hiding bottom sheet
                      //   Navigator.pop(context);
                      // });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: screenSize.width * .04,
                indent: screenSize.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                            context.pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      // Navigator.pop(context);
                      // APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends ConsumerWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
            final screenSize = ref.read(sizeProvider);

    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: screenSize.width * .05,
              top: screenSize.height * .015,
              bottom: screenSize.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
