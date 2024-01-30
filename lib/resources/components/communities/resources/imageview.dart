import 'package:flutter/material.dart';

class ImageDekhlo extends StatefulWidget {
  String url;
  ImageDekhlo({
    required this.url,
  });
  @override
  State<ImageDekhlo> createState() => _ImageDekhloState(
        url: url,
      );
}

class _ImageDekhloState extends State<ImageDekhlo> {
  String url;
  _ImageDekhloState({
    required this.url,
  });
  @override
  Widget build(BuildContext context) {
    return Image.network(url);
  }
}