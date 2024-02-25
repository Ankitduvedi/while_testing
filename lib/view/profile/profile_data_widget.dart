import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:com.example.while_app/view/profile/user_profile_follower_screen.dart';
import 'package:com.example.while_app/view/profile/user_profile_following_screen.dart';
import '../../main.dart';
import '../../resources/components/bottom_options_sheet.dart';

class ProfileDataWidget extends ConsumerWidget {
  ProfileDataWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    final user = ref.watch(userDataProvider).userData;
    return SafeArea(
        child: LiquidPullToRefresh(
      onRefresh: () async {
        // Add your refresh logic here
        await Future.delayed(const Duration(seconds: 2));
        // Update the UI after refreshing
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(50, 50),
                  bottomRight: Radius.elliptical(50, 50),
                ),
                child: Image.asset(
                  'assets/profile_bg.jpg',
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  height: h * 0.25,
                ),
              ),
              Container(
                width: double.infinity,
                height: h * 0.27,
                child: Center(
                  child: Container(
                    height: h * 0.12,
                    width: w * 0.25,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: user!.image,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: h * 0.02,
                left: mq.width / 1.15,
                //right: mq.width /290.15,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const MoreOptions();
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              Positioned(
                top: h * 0.2,
                left: w * 0.1,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    width: w * 0.8,
                    //height: h*0.1,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                          ),
                        ),
                        const SizedBox(height: 1.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserProfileFollowerScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.person,
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserProfileFollowerScreen(),
                                        ),
                                      );
                                    },
                                    child: _buildStatItem(
                                        "${user.follower}", 'Followers')),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserProfileFollowingScreen(
                                                chatUser: user),
                                      ),
                                    );
                                  },
                                  icon: const Icon((Icons.people), size: 35),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserProfileFollowingScreen(
                                                chatUser: user),
                                      ),
                                    );
                                  },
                                  child: _buildStatItem(
                                      "${user.following}", 'Following'),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.video_camera_front,
                                  size: 35,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                _buildStatItem("0", 'Posts     '),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.download,
                                  size: 35,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                _buildStatItem("0", 'Downloads'),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 86,
          )
        ],
      ),
    ));
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
