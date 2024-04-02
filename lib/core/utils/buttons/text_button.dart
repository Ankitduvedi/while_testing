import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Textbutton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  const Textbutton({super.key, required this.ontap, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: ontap,
        child: Text(text, style: const TextStyle(fontSize: 20)));
  }
}
