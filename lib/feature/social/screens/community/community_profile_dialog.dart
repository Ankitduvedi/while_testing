import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../../data/model/community_user.dart';

class CommunityProfileDialog extends ConsumerWidget {
  const CommunityProfileDialog({super.key, required this.user});

  final Community user;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
            final screenSize = ref.read(sizeProvider);

    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 20),
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: screenSize.width * .6,
          height: screenSize.height * .35,
          child: Padding(
            padding: EdgeInsets.only(right: screenSize.width * .06),
            child: Stack(
              children: [
                //user profile picture
                Positioned(
                  top: screenSize.height * .075,
                  left: screenSize.width * .06,
                  child: ClipRRect(
                    // borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                    child: CachedNetworkImage(
                      width: screenSize.width * .6,
                      fit: BoxFit.fill,
                      imageUrl: user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                //user name
                Positioned(
                  left: screenSize.width * .06,
                  top: screenSize.height * .02,
                  width: screenSize.width * .55,
                  child: Text(user.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ),

                //info button
                Positioned(
                    right: 8,
                    top: 6,
                    child: MaterialButton(
                      onPressed: () {
                        // print('pressed///////////////');
                        //for hiding image dialog
                        // Navigator.pop(context);

                        // //move to view profile screen
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ViewProfileScreen(user: user)));
                      },
                      minWidth: 0,
                      padding: const EdgeInsets.all(0),
                      shape: const CircleBorder(),
                      child: const Icon(Icons.info_outline,
                          color: Colors.blue, size: 30),
                    ))
              ],
            ),
          )),
    );
  }
}
