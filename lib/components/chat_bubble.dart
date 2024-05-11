import 'package:flutter/material.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final String timestamp;
  final Color bubbleColor;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.timestamp,
      required this.bubbleColor,
      });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.bubbleColor,
      ),
      child: Column(
        children: [
          TimestampedChatMessage(
            text: widget.message,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            sentAt: widget.timestamp.toString(),
          ),
        ],
      ),
    );
  }
}

