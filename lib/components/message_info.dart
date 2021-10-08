import 'package:bytebank2/components/centered_message.dart';
import 'package:flutter/material.dart';

class MessageInfo extends StatelessWidget {
  const MessageInfo(this.message, {Key? key}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return CenteredMessage(
      message,
      icon: Icons.info,
      color: Colors.blue,
    );
  }
}
