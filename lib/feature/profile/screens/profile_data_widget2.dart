import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/profile/screens/bottom_options_sheet.dart';
import 'package:com.while.while_app/feature/profile/screens/edit_profile_user.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_follower_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_following_screen.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDataWidget extends ConsumerWidget {
  const ProfileDataWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double h = MediaQuery.of(context).size.height;

    final user = ref.watch(userDataProvider).userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: h * 0.14,
          width: h * 0.14,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h * 0.7),
            child: CachedNetworkImage(
              imageUrl: user!.image,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          user.name,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              height: 2,
              letterSpacing: 1,
              color: const Color.fromARGB(255, 51, 51, 51),
              fontWeight: FontWeight.w700),
        ),
        Text(
          user.email,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              height: 1,
              letterSpacing: 1,
              color: const Color.fromARGB(255, 183, 177, 177),
              fontWeight: FontWeight.w300),
        ),
        Text(
          user.about,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              height: 3,
              letterSpacing: 1,
              color: const Color.fromARGB(255, 79, 79, 79),
              fontWeight: FontWeight.w400),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("0", 'Posts'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileFollowerScreen(chatUser: user),
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
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Check for errors
                      if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              ),
                            );
                          } else {
                            // Handle the case where data is null
                            return Text(
                              '0',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              ),
                            );
                          }
                      }
                    },
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    "Followers",
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 79, 79, 79),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileFollowingScreen(chatUser: user),
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
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Check for errors
                      if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
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
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              ),
                            );
                          } else {
                            // Handle the case where data is null
                            return Text(
                              '0',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                              ),
                            );
                          }
                      }
                    },
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    "Following",
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 79, 79, 79),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GradientFilledButton(
              text: 'Edit Profile',
              onPressed: () {
                // Handle button press
              },
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(230, 77, 255, 1),
                  Color.fromRGBO(123, 68, 212, 1),
                ],
              ),
            ),
            GradientOutlinedButton(
              text: 'Settings',
              onPressed: () {
                // Handle button press
              },
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(230, 77, 255, 1),
                  Color.fromRGBO(123, 68, 212, 1),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: const Color.fromARGB(255, 79, 79, 79),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class GradientOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;

  const GradientOutlinedButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1), // Border width
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white, // Background color inside the button
            side: const BorderSide(
              color: Colors.transparent, // Border color inside the button
              width: 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const MoreOptions();
              },
            );
          },
          child: ShaderMask(
            shaderCallback: (bounds) {
              return gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              );
            },
            child: Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;

  const GradientFilledButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EditUserProfileScreen()));
        },
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
