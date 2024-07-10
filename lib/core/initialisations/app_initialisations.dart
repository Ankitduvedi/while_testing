import 'dart:developer';
 import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get.dart';

class AppInitializations {
  final FlutterNotificationChannel _notificationChannel = FlutterNotificationChannel();

  Future<void> initializeFirebaseServices() async {
    await _initializeNotificationChannels();
    await _initializeDynamicLinks();
  }

  Future<void> _initializeNotificationChannels() async {
    try {
      await _notificationChannel.registerNotificationChannel(
        description: 'For showing notifications',
        id: 'chats',
        importance: NotificationImportance.IMPORTANCE_HIGH,
        name: 'WHILE',
      );
      log('Notification channels initialized');
    } catch (e) {
      log('Failed to initialize notification channels: $e');
      // Handle error or notify user
    }
  }

  Future<void> _initializeDynamicLinks() async {
    try {
      log('Initializing Dynamic Links');
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
        _handleDynamicLink(dynamicLinkData);
      });

      final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
      if (initialLink != null) {
        _handleDynamicLink(initialLink);
      }
    } catch (e) {
      log('Failed to initialize dynamic links: $e');
      // Handle error or notify user
    }
  }

  void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
    try {
      final Uri deepLink = dynamicLinkData.link;
      final route = deepLink.queryParameters['screen'];
      final url = deepLink.queryParameters['url'];

      if (route != null) {
        log('Navigating to $route with parameter: $url');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(
            route,
          );
        });
      } else {
        log('Invalid dynamic link');
      }
    } catch (e) {
      log('Failed to handle dynamic links: $e');
    }
  }
}
