import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/main.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SelectThumbnailScreen extends ConsumerStatefulWidget {
  final String initialThumbnailUrl;
  final String videoId;
  final String category;

  const SelectThumbnailScreen(
      {Key? key,
      required this.category,
      required this.initialThumbnailUrl,
      required this.videoId})
      : super(key: key);

  @override
  SelectThumbnailScreenState createState() => SelectThumbnailScreenState();
}

class SelectThumbnailScreenState extends ConsumerState<SelectThumbnailScreen> {
  File? _image;
  bool _isImageSelected = false; // Tracks if an image has been selected

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageSelected = true; // Image has been selected
      });
    }
  }

  void updateThumbnail(String thumnailUrl, String videoId) async {
    String libraryId = '243538';
    String accessKey = '6973830f-6890-472d-b8e3b813c493-5c4d-4c50';

    var url = Uri.parse(
        'https://video.bunnycdn.com/library/$libraryId/videos/$videoId/thumbnail?thumbnailUrl=$thumnailUrl');

    var response = await http.post(
      url,
      headers: {
        'AccessKey': accessKey,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("videoId: $videoId");
      FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.category)
          .collection(widget.category)
          .doc(videoId)
          .update({"thumbnail": thumnailUrl});
      var userId = ref.read(userDataProvider)!.userData?.id;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('videos')
          .doc(videoId)
          .update({"thumbnail": thumnailUrl});
      print('Thumbnail updated successfully');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
    Navigator.pop(context);
  }

  void _uploadThumnail() async {
    final file = _image;

    final String fileName = path.basename(_image!.path);
    String downloadUrl = '';
    final url = Uri.parse('https://storage.bunnycdn.com/while3/$fileName');
    String accessKey = '4573db24-8174-44e1-bb83f462173b-7d2a-4141';

    final headers = {
      'AccessKey': accessKey,
      'Content-Type': 'application/octet-stream',
      'accept': 'application/json',
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: await _image?.readAsBytes(),
      );

      if (response.statusCode == 201) {
        print('File uploaded successfully');
        downloadUrl = 'https://while3.b-cdn.net/$fileName';
        updateThumbnail(downloadUrl, widget.videoId);
      } else {
        print(
            'Failed to upload file: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Thumbnail"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                elevation: 5, // Shadow depth
                child: ClipRRect(
                  // Ensures the child content respects the rounded corners
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: mq.height / 1.5,
                    decoration: BoxDecoration(
                      // Optional: Border
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.3), width: 1),
                      // Optional: Gradient overlay for network images
                      gradient: _image == null
                          ? LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                widget.initialThumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                              // Optional: Dark gradient overlay at the bottom
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Select Image from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isImageSelected
                    ? _uploadThumnail
                    : null, // Enabled only if an image is selected
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Set a different color to distinguish it
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child:
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
