import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.example.while_app/utils/routes/routes_name.dart';

class ReelController with ChangeNotifier {
  final picker = ImagePicker();
  late File _selectedVideo;

  File get selectedVideo => _selectedVideo;

  Future<void> selectVideo(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          "Select Video Source",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Replace with your desired color
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Replace with your desired color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Replace with your desired color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Camera',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickVideo(source: source);
      if (pickedFile != null) {
        _selectedVideo = File(pickedFile.path);
        Navigator.pushNamed(context, RoutesName.addReel,
            arguments: pickedFile.path);
        notifyListeners();
      }
    }
  }
}
