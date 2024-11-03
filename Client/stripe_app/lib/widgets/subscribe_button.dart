// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SubscribeButton extends StatefulWidget {
  final String title;
  final VoidCallback onPress;
  const SubscribeButton({
    super.key,
    required this.title,
    required this.onPress,
  });

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPress,
      style: ElevatedButton.styleFrom(),
      child: Text(widget.title),
    );
  }
}
