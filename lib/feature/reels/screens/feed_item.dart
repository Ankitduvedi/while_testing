import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:com.while.while_app/data/model/video_model.dart';

class FeedItem extends StatefulWidget {
  FeedItem({
    super.key,
    required this.video,
    required this.index,
    required this.baseVideoUrl,
    required this.controller,
  });

  final Video video;
  final int index;
  final String baseVideoUrl;
  VideoPlayerController controller;

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  User? user = FirebaseAuth.instance.currentUser;

  bool likeTapped = false;
  bool showPlayPauseButton = false;
  ConnectivityResult? _connectionStatus;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();

    initializePlayer();

    // likeTapped = false;
    // _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // _initializeVideoPlayerBasedOnConnection();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    print("result is $result");
    setState(() {
      print("result is $result");
      _connectionStatus = result[0];
      _initializeVideoPlayerBasedOnConnection();
    });
  }

  void _initializeVideoPlayerBasedOnConnection() {
    String maxRes = widget.video.maxVideoRes;
    String quality = '360p'; // Default quality
    List<String> qualityOptions = [
      '144p',
      '240p',
      '360p',
      '480p',
      '720p',
      '1080p'
    ];

    if (_connectionStatus != null) {
      if (_connectionStatus == ConnectivityResult.wifi ||
          _connectionStatus == ConnectivityResult.mobile) {
        quality = _getBestQuality(maxRes, qualityOptions);
      }
    }

    // _initializeVideoPlayer(quality);
  }

  String _getBestQuality(String maxRes, List<String> qualityOptions) {
    for (var quality in qualityOptions.reversed) {
      if (_isResolutionLessThanOrEqual(quality, maxRes)) {
        return quality;
      }
    }
    return qualityOptions
        .first; // Default to the lowest quality if no match found
  }

  bool _isResolutionLessThanOrEqual(String quality, String maxRes) {
    // Convert quality string to integer value for comparison
    int qualityValue = int.parse(quality.replaceAll('p', ''));
    int maxResValue = int.parse(maxRes.replaceAll('p', ''));
    return qualityValue <= maxResValue;
  }

  // void _initializeVideoPlayer(String quality) {
  //   final videoUrl = '${widget.baseVideoUrl}/play_$quality.mp4';
  //   print("videourl is $videoUrl");
  //   setState(() {
  //     _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
  //       ..initialize().then((_) {
  //         setState(() {});
  //         _controller.play();
  //       });
  //   });
  // }

  void _showQualityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return QualityOptions(
          maxRes: widget.video.maxVideoRes,
          onQualitySelected: _onQualitySelected,
        );
      },
    );
  }

  void _onQualitySelected(String quality) async {
    await widget.controller.pause();
    await widget.controller.dispose();
    // _initializeVideoPlayer(quality);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // void _togglePlayPause() {
  //   setState(() {
  //     if (_controller.value.isPlaying) {
  //       _controller.pause();
  //     } else {
  //       _controller.play();
  //     }
  //   });
  // }

  bool videoUPdate = false;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isPotrait = true;

  Future<void> initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.video.videoUrl);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      showControls: true,
      showOptions: true,
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    _chewieController!.addListener(() {
      setState(() {});
      if (_chewieController!.isFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
        });
        setState(() {});
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        });
        setState(() {});
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title:
                Text('While Network', style: TextStyle(color: Colors.white))),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Colors.black),
          child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Stack(
                  children: [
                    Chewie(
                      controller: _chewieController!,
                    ),
                    // VideoPlayer(_controller),
                    // if (showPlayPauseButton)
                    //   Center(
                    //     child: IconButton(
                    //       icon: Icon(
                    //         _controller.value.isPlaying
                    //             ? Icons.pause
                    //             : Icons.play_arrow,
                    //         color: Colors.white,
                    //         size: 50.0,
                    //       ),
                    //       onPressed: _togglePlayPause,
                    //     ),
                    //   ),
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Report'),
                          ),
                        ),
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Block'),
                          ),
                        ),
                      ];
                    }),
                    Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        widget.video.title,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      Text(
                                        widget.video.description,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                      ],
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01,
                      child: IconButton(
                        onPressed: () {
                          _showQualityOptions(context);
                        },
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: NetworkImage(widget.video.thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
        ));
  }
}

class QualityOptions extends StatelessWidget {
  final String maxRes;
  final Function(String) onQualitySelected;

  QualityOptions({required this.maxRes, required this.onQualitySelected});

  @override
  Widget build(BuildContext context) {
    List<String> allQualityOptions = [
      '1080p',
      '720p',
      '480p',
      '360p',
      '240p',
      '144p'
    ];
    List<String> filteredQualityOptions = allQualityOptions
        .where((quality) => _isResolutionLessThanOrEqual(quality, maxRes))
        .toList();

    return Container(
      padding: EdgeInsets.all(16.0),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Video Quality',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: filteredQualityOptions.map((quality) {
                return ListTile(
                  title: Text(quality),
                  onTap: () => onQualitySelected(quality),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isResolutionLessThanOrEqual(String quality, String maxRes) {
    int qualityValue = int.parse(quality.replaceAll('p', ''));
    int maxResValue = int.parse(maxRes.replaceAll('p', ''));
    return qualityValue <= maxResValue;
  }
}
