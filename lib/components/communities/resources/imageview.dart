// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ImageDekhlo extends StatefulWidget {
  String url;
  ImageDekhlo({
    Key? key,
    required this.url,
  }) : super(key: key);
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