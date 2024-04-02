import 'package:flutter/material.dart';

class ImageDekhlo extends StatefulWidget {
  final String url;
  
  const ImageDekhlo({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<ImageDekhlo> createState() => _ImageDekhloState();
}

class _ImageDekhloState extends State<ImageDekhlo> {
  @override
  Widget build(BuildContext context) {
    // Access `url` directly from the widget property
    return Image.network(widget.url);
  }
}
