import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class TextContainerWidget extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? hintText;
  final double? borderRadius;
  final Color? color;

  final void Function()? iconClickEvent;
  const TextContainerWidget({
    Key? key,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.hintText,
    this.borderRadius = 10,
    this.color,
    this.iconClickEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 5.0,
            offset: Offset(-4, -4),
            inset: true,
          ),
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(4, 4),
            inset: true,
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.titleMedium,
          border: InputBorder.none,
          prefixIcon: InkWell(
            onTap: iconClickEvent,
            child: Icon(prefixIcon),
          ),
        ),
      ),
    );
  }
}
