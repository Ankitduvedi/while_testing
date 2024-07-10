// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> addSiteTargetPage(
    {required GlobalKey homeKey,
    required GlobalKey videoKey,
    required GlobalKey playKey,
    required GlobalKey chatKey,
    required GlobalKey profileKey}) {
  List<TargetFocus> targets = [];

  targets.add(TargetFocus(
    keyTarget: homeKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.Circle,
    contents: [
      TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Return to your personalized feed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          })
    ],
  ));
  targets.add(
    TargetFocus(
      keyTarget: videoKey,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Videos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dive into comprehensive learning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            })
      ],
    ),
  );
  targets.add(TargetFocus(
    keyTarget: playKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.Circle,
    contents: [
      TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loops',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore short , engaging loops',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          })
    ],
  ));
  targets.add(TargetFocus(
    keyTarget: chatKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.Circle,
    contents: [
      TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Connect and collaborate with peers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          })
    ],
  ));
  targets.add(TargetFocus(
    keyTarget: profileKey,
    alignSkip: Alignment.topRight,
    radius: 10,
    shape: ShapeLightFocus.Circle,
    contents: [
      TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Manage your profile',
                    style:   TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          })
    ],
  ));
  return targets;
}
