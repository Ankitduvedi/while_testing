import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> addChatsSiteTargetPage({
  required GlobalKey connectKey,
  required GlobalKey chatsKey,
  required GlobalKey communityKey,
  required GlobalKey statusKey,
}) {
  List<TargetFocus> targets = [];

  targets.add(TargetFocus(
    keyTarget: connectKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Network now! or Expand your Network',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ));

  targets.add(TargetFocus(
    keyTarget: chatsKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Start a conversation',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ));

  targets.add(TargetFocus(
    keyTarget: communityKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Be part of the community.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ));

  targets.add(TargetFocus(
    keyTarget: statusKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.RRect,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Flex your achievements',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ));

  return targets;
}
