import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/utils/buttons/round_button.dart';
import 'package:com.while.while_app/core/utils/containers_widgets/text_container_widget.dart';
import 'package:com.while.while_app/core/utils/players/video_player.dart';
import 'package:com.while.while_app/data/model/video_model.dart';
import 'package:com.while.while_app/feature/upload/repository/provider.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tus_client/tus_client.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'package:com.while.while_app/core/utils/utils.dart';
import 'package:flutter_video_info/flutter_video_info.dart';

class AddVideo extends ConsumerStatefulWidget {
  final XFile video;

  const AddVideo({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<AddVideo> createState() => AddVideoState();
}

class AddVideoState extends ConsumerState<AddVideo> {
  late Subscription _subscription;
  bool isloading = false;
  double _uploadProgress = 0.0;
  bool uploading = false;
  String selectedOption = 'App Development';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      setState(() {
        _uploadProgress = progress / 100;
        //isloading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  compressVideo(String videoPath) async {
    log("video path is $videoPath");
    MediaInfo? infov;
    try {
      final info = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      setState(() {
        infov = info;
      });
    } catch (e) {
      log("error is $e");
      VideoCompress.cancelCompression();
    }

    return infov!.file;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Video"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: w,
                  height: h / 1.75,
                  child: VideoPlayerWidget(videoPath: widget.video.path),
                ),
              ),
              const SizedBox(height: 15),
              if (!isloading)
                TextContainerWidget(
                  keyboardType: TextInputType.text,
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  hintText: 'Title',
                ),
              const SizedBox(height: 10),
              if (!isloading)
                TextContainerWidget(
                  keyboardType: TextInputType.text,
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  hintText: 'Description',
                ),
              const SizedBox(height: 10),
              if (!isloading)
                categoriesAsyncValue.when(
                  data: (categories) {
                    return _buildDropDown(
                      "Select Category",
                      selectedOption,
                      categories,
                      (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
              const SizedBox(height: 5),
              if (isloading)
                LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                    value: _uploadProgress,
                    semanticsValue: uploading ? 'Uploading' : 'Compression',
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        uploading ? Colors.blue : Colors.red)),
              const SizedBox(height: 10),
              if (isloading)
                Text(
                  uploading ? 'Uploading...' : 'Compression...',
                  style: const TextStyle(fontSize: 20),
                ),
              if (isloading) const SizedBox(height: 10),
              RoundButton(
                title: "Upload",
                loading: isloading,
                onPress: () {
                  if (_titleController.text.isEmpty) {
                    Utils.flushBarErrorMessage('Please enter title', context);
                  } else if (_descriptionController.text.isEmpty) {
                    Utils.flushBarErrorMessage(
                        'Please enter description', context);
                  } else {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _handleUpload();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final String _apiKey = '6973830f-6890-472d-b8e3b813c493-5c4d-4c50';
  final String _libraryId = '243538';
  final String _CDN_host = 'vz-f0994fc7-d98.b-cdn.net';

  Future<List<String>> fetchCategoriesFromFirestore() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('videosCategories').get();
    List<String> categories = [];
    for (var doc in categoriesSnapshot.docs) {
      String categoryName =
          doc.data()['category']; // Assuming each document has a 'name' field
      categories.add(categoryName);
    }
    return categories;
  }

  Widget _buildDropDown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple, fontSize: 18),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _handleUpload() async {
    setState(() {
      isloading = true;
      _uploadProgress = 0.0;
    });
    log('entered in _handleUpload');

    try {
      final videoId = await _createVideo(
          _titleController.text, _descriptionController.text);

      final signatureParts = _generateSignature(videoId).split(',');
      _uploadVideo(videoId, signatureParts[0], signatureParts[1]);
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(this.context)
          .showSnackBar(SnackBar(content: Text('Failed to prepare video: $e')));
      Navigator.pop(context);
    }
  }

  void _uploadVideo(
      String videoId, String signature, String expirationTime) async {
    log("videopath is ${widget.video.path}");
    File vid = await compressVideo(widget.video.path);

    XFile video = XFile(vid.path);
    final videoInfo = FlutterVideoInfo();
    var info = await videoInfo.getVideoInfo(vid.path);
    log("height is ${info?.height.toString()}  width is ${info?.width.toString()}");
    String height = info?.height.toString() ?? "";
    log("info is $info");
    int len = await video.length();

    final endpointUrl = Uri.parse('https://video.bunnycdn.com/tusupload');
    final client = TusClient(endpointUrl, video, headers: {
      'AuthorizationSignature': signature.split(',')[0],
      'AuthorizationExpire': expirationTime,
      'VideoId': videoId,
      'LibraryId': _libraryId,
    });

    try {
      await client.upload(
        onComplete: () async {
          final uploadedVideo = Video(
              maxVideoRes: '1080',
              id: videoId,
              category: selectedOption,
              uploadedBy: ref.read(userDataProvider).userData!.id,
              videoUrl: 'https://$_CDN_host/${videoId}/play_360p.mp4',
              thumbnail: 'https://$_CDN_host/${videoId}/thumbnail.jpg',
              title: _titleController.text,
              description: _descriptionController.text,
              likes: [],
              views: 0,
              creatorName: ref.read(userDataProvider).userData!.name);
          log('Selected category before firebase $selectedOption');
          FirebaseFirestore.instance
              .collection('videos')
              .doc(selectedOption)
              .collection(selectedOption)
              .doc(videoId)
              .set(uploadedVideo.toJson());
          log('value of user id is = ${ref.read(userDataProvider).userData!.id}');
          FirebaseFirestore.instance
              .collection('users')
              .doc(ref.read(userDataProvider).userData!.id)
              .collection('videos')
              .doc(videoId)
              .set(uploadedVideo.toJson());
          Utils.toastMessage('Your video is uploaded!');
          setState(() {
            isloading = false;
          });

          Navigator.pop(context);
        },
        onProgress: (progress) {
          uploading = true;
          log("Progress: $progress");
          setState(() {
            _uploadProgress = progress / 100;
          });
        },
      );

      log('Video uploaded successfully!');
    } catch (e) {
      log('Upload failed: $e');
      setState(() {
        isloading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<String> _createVideo(String title, String description) async {
    log('entered in createvideo');

    final response = await http.post(
      Uri.parse('https://video.bunnycdn.com/library/$_libraryId/videos'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'AccessKey': _apiKey,
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('response code is ${response.statusCode}, ${data['guid']} ');

      return data['guid'];
    } else {
      log('Failed to create video: ${response.body} , ');
      Navigator.pop(context);
      throw Exception(
          'Failed to create video: ${response.body}, ${response.statusCode}');
    }
  }

  String _generateSignature(String videoId) {
    log('entered in _generateSignature');

    final expirationTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final signatureString =
        '$_libraryId' + '$_apiKey' + '$expirationTime' + '$videoId';
    final hash = sha256.convert(utf8.encode(signatureString)).toString();
    return '$hash,$expirationTime';
  }
}
