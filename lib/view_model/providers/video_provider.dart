import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/data/model/video_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allVideosProvider = StreamProvider<List<Video>>((ref) {
  log('allUsersProvider');
  return FirebaseFirestore.instance
      .collection('videos')
      .doc('Block Chain')
      .collection('Block Chain')
      .snapshots()
      .map((snapshot) {
    // First, map all documents to ChatUser objects
    log('videoList.length.toString()///');

    var videoList =
        snapshot.docs.map((doc) => Video.fromMap(doc.data())).toList();
    log('videoList.length.toString()');

    log(videoList.length.toString());
    return videoList;
  });
});
