import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_follower_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_following_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDataWidget extends ConsumerWidget {
  const ProfileDataWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    final user = ref.watch(userProvider);

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
                      imageUrl: user!.image,
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
                        builder: (_) =>
                            UserProfileFollowerScreen(chatUser: user),
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
                            .doc(user.id)
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
                              return const CircularProgressIndicator();

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
                            UserProfileFollowingScreen(chatUser: user),
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
                            .doc(user.id)
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
                              return const CircularProgressIndicator();

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
                    user.about,
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
