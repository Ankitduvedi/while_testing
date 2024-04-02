import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SelectThumbnailScreen extends ConsumerStatefulWidget {
  final String initialThumbnailUrl;
  final String videoId;

  const SelectThumbnailScreen(
      {Key? key, required this.initialThumbnailUrl, required this.videoId})
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

  void _updateThumbnail() async {
    log('update button pressed');
    const String apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
    const apiUrl = 'https://sandbox.api.video';
    //Uri endpoint = Uri.parse('$apiUrl$widget.videoId/thumbnail');
    var request = http.MultipartRequest(
        'POST', Uri.parse('$apiUrl/videos/${widget.videoId}/thumbnail'))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..files.add(await http.MultipartFile.fromPath(
          'file', _image!.path)); // Constructing the full URL

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Successfully updated the thumbnail
        final Map<String, dynamic> data =
            json.decode(await response.stream.bytesToString());
        log(data['assets']['thumbnail']);
        log('Thumbnail updated successfully.');
        FirebaseFirestore.instance
            .collection('loops')
            .doc(widget.videoId)
            .update({"thumbnail": data['assets']['thumbnail']});
        FirebaseFirestore.instance
            .collection('users')
            .doc(ref.read(userProvider)!.id)
            .collection('loops')
            .doc(widget.videoId)
            .update({"thumbnail": data['assets']['thumbnail']});
      } else {
        // Handle errors
        log('Failed to update the thumbnail. Status code: ${response.statusCode}');
        //print('Response body: ${response.body}');
      }
    } catch (e) {
      log('An error occurred: $e');
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
                    ? _updateThumbnail
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
