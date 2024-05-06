import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/utils/buttons/round_button.dart';
import 'package:com.while.while_app/core/utils/containers_widgets/text_container_widget.dart';
import 'package:com.while.while_app/core/utils/players/video_player.dart';
import 'package:com.while.while_app/data/model/reels_models.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:tus_client/tus_client.dart';

class AddReel extends ConsumerStatefulWidget {
  final String video;
  const AddReel({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<AddReel> createState() => _AddReelState();
}

class _AddReelState extends ConsumerState<AddReel> {
  late Subscription _subscription;
  bool isloading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      isloading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality, deleteOrigin: false);
    return compressedVideo?.file;
  }

  void uploadVideo(BuildContext context, String title, String des, String path,
      List likes, int shares) async {
    setState(() {
      isloading = true;
    });
    _handleUpload();
    File vid = await compressVideo(path);
    Dialogs.showSnackbar(context, vid.path.split(".").last);
// Api.video
    uploadVideo(File videoFile, String id) async {
      //Dialogs.showSnackbar(context, 'Function called');
      const apiKey = '6Rdwzgfec9nfQmGXn523qoQiuKHhuDCO0o31bcis2Da';
      const apiUrl = 'https://ws.api.video/videos';

      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl/$id/source'))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      try {
        var response = await request.send();
        //Dialogs.showSnackbar(context, 'Trying');
        if (response.statusCode == 201) {
          // Video uploaded successfully
          final Map<String, dynamic> data =
              json.decode(await response.stream.bytesToString());
          //Dialogs.showSnackbar(context, data['videoId']);
          //Dialogs.showSnackbar(context, data['assets']['thumbnail']);
          final Loops loop = Loops(
              creatorName: ref.read(userProvider)!.name,
              id: id,
              uploadedBy: ref.read(userProvider)!.id,
              videoUrl: data['assets']['mp4'],
              thumbnail: data['assets']['thumbnail'],
              title: title,
              description: des,
              likes: likes,
              views: 0,
              category: 'category');

          FirebaseFirestore.instance
              .collection('loops')
              .doc(id)
              .set(loop.toJson())
              .then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(ref.read(userProvider)!.id)
                .collection('loops')
                .doc(id)
                .set(loop.toJson());
            Utils.toastMessage('Your video is uploaded!');
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            return data['videoId'];
          });
        } else {
          // Handle upload failure
          //Dialogs.showSnackbar(context, 'Failed');
          throw Exception('Failed to upload video');
        }
      } catch (e) {
        // Handle exceptions
        //Dialogs.showSnackbar(context, e.toString());
        log('Error uploading video: $e');
        throw Exception('Failed to upload video');
      }
    }

    createVideo(String title, String description) async {
      Dialogs.showSnackbar(context, 'Called');
      const apiKey = '6Rdwzgfec9nfQmGXn523qoQiuKHhuDCO0o31bcis2Da';
      const apiUrl = 'https://ws.api.video';
      final response = await http.post(
        Uri.parse('$apiUrl/videos'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          // 'Content-Length': '', // Add the length of the request body here
          // 'Host': 'sandbox.api.video',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        uploadVideo(vid, data['videoId']);
      } else {
        Dialogs.showSnackbar(context, 'Failed');
        throw Exception('Failed to create video');
      }
    }

    createVideo(title, des);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 1;
    final w = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reel"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: w,
                  height: h / 2,
                  child: VideoPlayerWidget(videoPath: widget.video),
                ),
              ),
              const SizedBox(height: 15),
              TextContainerWidget(
                keyboardType: TextInputType.text,
                controller: _titleController,
                prefixIcon: Icons.title,
                hintText: 'Title',
              ),
              const SizedBox(height: 10),
              TextContainerWidget(
                keyboardType: TextInputType.text,
                controller: _descriptionController,
                prefixIcon: Icons.description,
                hintText: 'Description',
              ),
              const SizedBox(
                height: 10,
              ),
              RoundButton(
                  title: "Add Reel",
                  loading: isloading,
                  onPress: () {
                    if (_titleController.text.isEmpty) {
                      Utils.flushBarErrorMessage('Please enter title', context);
                    } else if (_descriptionController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                          'Please enter description', context);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      uploadVideo(
                          context,
                          _titleController.text.toString(),
                          _descriptionController.text.toString(),
                          widget.video.toString(),
                          [], // initally the likes list shall be holding an empty list to be precise
                          0);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

// Add 'tus_client' package to your pubspec.yaml

  final String _title = 'abcdef';
  final String _description = 'edfdef';
  XFile? _videoFile;

  final String _apiKey = '5d92156c-5900-42a8-911500a7e326-350d-46d5';
  final String _libraryId = '235359';

  Future<String> _createVideo(String title, String description) async {
    log('entered in createvideo');

    final response = await http.post(
      Uri.parse('https://video.bunnycdn.com/library/$_libraryId/videos'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'AccessKey': _apiKey,
      },
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('response code is ${response.statusCode}');

      return data['guid'];
    } else {
      log('Failed to create video: ${response.body} , ');
      throw Exception(
          'Failed to create video: ${response.body}, ${response.statusCode}');
    }
  }

  String _generateSignature(String videoId) {
    log('entered in _generateSignature');

    final expirationTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final signatureString = '$_libraryId$_apiKey$expirationTime$videoId';
    final hash = sha256.convert(utf8.encode(signatureString)).toString();
    return '$hash,$expirationTime';
  }

  void _uploadVideo(
      String videoId, String signature, String expirationTime) async {
    log('entered in _uploadVideo');
    final endpointUrl = Uri.parse('https://video.bunnycdn.com/tusupload');
    final client = TusClient(endpointUrl, _videoFile!)
      ..headers = {
        'AuthorizationSignature': signature.split(',')[0],
        'AuthorizationExpire': expirationTime,
        'VideoId': videoId,
        'LibraryId': _libraryId,
      };

    try {
      log('entered in _uploadVideo and trying');

      await client.upload(
        onComplete: () {
          log("Complete!");

          // Prints the uploaded file URL
          log(client.uploadUrl.toString());
        },
        onProgress: (progress) {
          log("Progress: $progress");
        },
      );

      // Store video information in Firestore
      // final videoData = {
      //   'id': videoId,
      //   'title': _title,
      //   'description': _description,
      //   'creatorName': _userName,
      //   'uploadedBy': _auth.currentUser!.uid,
      //   'videoUrl':
      //       'https://iframe.mediadelivery.net/play/$_libraryId/$videoId',
      //   'thumbnail':
      //       'https://video.bunnycdn.com/library/$_libraryId/video/$videoId/thumbnail.jpg',
      // };

      // final batch = _db.batch();
      // final loopsRef = _db.collection('loops').doc(videoId);
      // final userLoopsRef = _db
      //     .collection('users')
      //     .doc(_auth.currentUser!.uid)
      //     .collection('loops')
      //     .doc(videoId);
      // batch.set(loopsRef, videoData);
      // batch.set(userLoopsRef, videoData);
      // await batch.commit();

      log('Video uploaded successfully!');
    } catch (e) {
      log('Upload failed: $e');
    }
  }

  Future<void> _handleUpload() async {
    log('entered in _handleUpload');

    try {
      final videoId = await _createVideo(_title, _description);
      final signatureParts = _generateSignature(videoId).split(',');
      _uploadVideo(videoId, signatureParts[0], signatureParts[1]);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to prepare video: $e')));
    }
  }
}
