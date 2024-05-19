import 'dart:developer';
import 'package:com.while.while_app/feature/upload/repository/upload_repository.dart';
import 'package:com.while.while_app/feature/upload/screens/add_reel.dart';
import 'package:com.while.while_app/feature/upload/screens/add_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadControllerProvider = Provider<UploadController>((ref) {
  return UploadController(uploadRepository: ref.read(uploadRepositoryProvider));
});

class UploadController {
  final UploadRepository _uploadRepository;

  UploadController({required UploadRepository uploadRepository})
      : _uploadRepository = uploadRepository;

  void selectVideo(BuildContext context, String type) async {
    final response = await _uploadRepository.selectVideo(context, type);
    response.fold((l) => const SnackBar(content: Text("failed to pick")), (r) {
      log(r.routeName);
      if (r.routeName == 'add_video') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVideo(video: r.selectedVideo),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReel(video: r.selectedVideo),
            ));
      }
    });
  }
}
