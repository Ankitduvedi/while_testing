import 'dart:io';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/feature/upload/screens/upload_screen.dart';
import 'package:com.while.while_app/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository();
});

class UploadRepository {
  final picker = ImagePicker();
  late File _selectedVideo;

  File get selectedVideo => _selectedVideo;

  Future<Either<Failure, VideoSelectionResult>> selectVideo(
      BuildContext context, String type) async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
          context: context,
          builder: (BuildContext context) => const UploadScreen());

      if (source == null) {
        return left(Failure(message: "Video source selection was canceled"));
      }

      final XFile? pickedFile = await picker.pickVideo(source: source);
      if (pickedFile == null) {
        return left(Failure(message: "No video was selected"));
      }

      // _selectedVideo = File(pickedFile.path);
      final String routeName =
          (type == 'Video') ? RoutesName.addVideo : RoutesName.addReel;

      // Now return both the route name and the _selectedVideo.
      return right(VideoSelectionResult(
          routeName: routeName, selectedVideo: pickedFile));
    } catch (e) {
      return left(Failure(
          message:
              "An error occurred while picking the video: ${e.toString()}"));
    }
  }
}

class VideoSelectionResult {
  final String routeName;
  final XFile selectedVideo;

  VideoSelectionResult({required this.routeName, required this.selectedVideo});
}
