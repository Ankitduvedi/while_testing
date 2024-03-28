import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/view/profile/friend_profile_follower_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/resources/components/message/apis.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/view/profile/friend_profile_following_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class FriendProfileDataWidget extends ConsumerStatefulWidget {
  const FriendProfileDataWidget({super.key, required this.chatUser});
  final ChatUser chatUser;
  @override
  ConsumerState<FriendProfileDataWidget> createState() =>
      FriendProfileDataWidgetState();
}

class FriendProfileDataWidgetState
    extends ConsumerState<FriendProfileDataWidget> {
  String? _image;

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var nh = MediaQuery.of(context).viewPadding.top;
    return SafeArea(
        child: LiquidPullToRefresh(
      onRefresh: () async {
        // Add your refresh logic here
        await Future.delayed(const Duration(seconds: 2));
        // Update the UI after refreshing
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: h * 0.12,
                  width: w * 0.27,
                  child: ClipOval(
                    //borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.chatUser.image,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.low,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                _buildStatItem("0", 'Posts'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => (FriendProfileFollowerScreen(
                                         chatUser: widget.chatUser,
                                         userIds: [],
                                       )),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.chatUser.id)
                            .collection('follower')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          // Check for errors
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.ptSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            );
                          }

                          // Check for connection state before attempting to access the data
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              // Show a loading indicator while waiting for the data
                              return CircularProgressIndicator();

                            default:
                              // Ensure data is not null before accessing it
                              if (snapshot.data != null) {
                                return Text(
                                  snapshot.data!.docs.length.toString(),
                                  style: GoogleFonts.ptSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                );
                              } else {
                                // Handle the case where data is null
                                return Text(
                                  '0',
                                  style: GoogleFonts.ptSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                );
                              }
                          }
                        },
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        "Followers",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            (FriendProfileFollowingScreen(
                                         chatUser: widget.chatUser,
                                         userIds: [],
                                       )),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.chatUser.id)
                            .collection('following')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          // Check for errors
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.ptSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            );
                          }

                          // Check for connection state before attempting to access the data
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              // Show a loading indicator while waiting for the data
                              return CircularProgressIndicator();

                            default:
                              // Ensure data is not null before accessing it
                              if (snapshot.data != null) {
                                return Text(
                                  snapshot.data!.docs.length.toString(),
                                  style: GoogleFonts.ptSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                );
                              } else {
                                // Handle the case where data is null
                                return Text(
                                  '0',
                                  style: GoogleFonts.ptSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                );
                              }
                          }
                        },
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        "Following",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "${widget.chatUser.about}",
                    style: GoogleFonts.ptSans(fontSize: 16),
                  )),
            ),
            // const SizedBox(
            //   height: 16,
            // ),
            
          ],
        ),
      ),
    ));
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.ptSans(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black54, fontSize: 15),
        ),
      ],
    );
  }
}

    
    
    
    
    
    
//     StreamBuilder(
//       stream: fireService.getMyUsersId(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           //if data is loading
//           case ConnectionState.waiting:
//           case ConnectionState.none:
//             return const SizedBox();

//           //if some or all data is loaded then show it
//           case ConnectionState.active:
//           case ConnectionState.done:
//             List<String> userIds =
//                 snapshot.data?.docs.map((e) => e.id).toList() ?? [];
//             return SizedBox(
//               width: double.infinity,
//               child: Stack(
//                 children: [
//                   Container(
//                     height: h / 2.5,
//                   ),
//                   Positioned(
//                     top: nh,
//                     child: InkWell(
//                         child: ClipRRect(
//                       // borderRadius: BorderRadius.circular(h * .13),
//                       child: CachedNetworkImage(
//                         width: h,
//                         fit: BoxFit.cover,
//                         height: h * .13,
//                         imageUrl: widget.chatUser.image,
//                         errorWidget: (context, url, error) =>
//                             const CircleAvatar(
//                                 child: Icon(CupertinoIcons.person)),
//                       ),
//                     )),
//                   ),
//                   Positioned(
//                     top: nh + h / 7 - w / 8,
//                     left: w / 12,

//                     //profile picture
//                     child: _image != null
//                         ?
//                         //local image
//                         ClipRRect(
//                             borderRadius: BorderRadius.circular(h * .1),
//                             child: Image.file(File(_image!),
//                                 width: h * .1,
//                                 height: h * .1,
//                                 fit: BoxFit.cover))
//                         :
//                         //image from server
//                         ClipRRect(
//                             borderRadius: BorderRadius.circular(h * .75),
//                             child: CachedNetworkImage(
//                               width: h * .15,
//                               height: h * .15,
//                               filterQuality: FilterQuality.low,
//                               fit: BoxFit.fill,
//                               imageUrl: widget.chatUser.image,
//                               errorWidget: (context, url, error) =>
//                                   const CircleAvatar(
//                                       child: Icon(CupertinoIcons.person)),
//                             ),
//                           ),
//                   ),
//                   Positioned(
//                       top: nh + h / 7.5,
//                       left: w / 2.25,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => (FriendProfileFollowingScreen(
//                                         chatUser: widget.chatUser,
//                                         userIds: userIds,
//                                       ))));
//                         },
//                         child: const Text(
//                           'Followers',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       )),
//                   Positioned(
//                       top: nh + h / 6.6,
//                       left: w / 1.6,
//                       child: const Text(
//                         "3",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       )),
//                   Positioned(
//                       top: nh + h / 6,
//                       left: w / 2.25,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => (FriendProfileFollowingScreen(
//                                         chatUser: widget.chatUser,
//                                         userIds: userIds,
//                                       ))));
//                         },
//                         child: const Text(
//                           'Following',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       )),
//                   // Positioned(
//                   //     top: nh + h / 7.5,
//                   //     left: w / 1.15,
//                   //     child: IconButton(
//                   //         onPressed: () {
//                   //           showModalBottomSheet(
//                   //               context: context,
//                   //               builder: (context) {
//                   //                 return MoreOptions(
//                   //                   user: user,
//                   //                 );
//                   //               });
//                   //         },
//                   //         icon: const Icon(
//                   //           Icons.more_vert,
//                   //           color: Colors.black,
//                   //         ))),

//                   Positioned(
//                       top: nh + h / 5.4,
//                       left: w / 1.6,
//                       child: StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(widget.chatUser.id)
//                               .collection('my_users')
//                               .snapshots(),
//                           builder: (context, snapshot) {
//                             switch (snapshot.connectionState) {
//                               //if data is loading
//                               case ConnectionState.waiting:
//                               case ConnectionState.none:
//                                 return const SizedBox();

//                               //if some or all data is loaded then show it
//                               case ConnectionState.active:
//                               case ConnectionState.done:
//                                 return Text(
//                                     snapshot.data!.docs.length.toString());
//                             }
//                           })),
//                   Positioned(
//                     top: nh + h / 7 + w / 8 + 30,
//                     child: Container(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.chatUser.name,
//                             style: const TextStyle(
//                                 fontSize: 25, fontWeight: FontWeight.w500),
//                           ),
//                           Text(widget.chatUser.about,
//                               style: const TextStyle(
//                                   fontSize: 15, fontWeight: FontWeight.w500))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//         }
//       },
//     );
//   }
// }
