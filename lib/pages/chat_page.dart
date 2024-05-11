import 'dart:async';

import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiveUserEmail;
  final String receiveUserID;

  const ChatPage({
    super.key,
    required this.receiveUserEmail,
    required this.receiveUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sendDataToFirebase();
  }

  void sendMessage() async {
    // only send a message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiveUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  void sendDataToFirebase() async {
    FirebaseFirestore.instance
        .collection('data')
        .add({'timestamp': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(
          widget.receiveUserEmail,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2c2c2c),
      ),
      backgroundColor: const Color(0xff2c2c2c),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/whatsapp_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // messages
            Expanded(child: _buildMessageList()),

            // user input
            _buildMessageInput(),

            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

// build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiveUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

// build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data["senderId"] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    Timestamp t = data['timestamp'] as Timestamp;
    DateTime date = t.toDate();

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          crossAxisAlignment:
              (data["senderId"] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data["senderId"] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["message"],
              timestamp:
                  "${"${date.hour}".padLeft(2, "0")}:${"${date.minute}".padLeft(2, "0")}",
              bubbleColor: (data["senderId"] == _firebaseAuth.currentUser!.uid)
                  ? const Color(0xff005c4b)
                  : const Color(0xff353535),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

// build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // textfield
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Enter a message",
              obscureText: false,
            ),
          ),

          ElevatedButton(
            onPressed: () {
              sendMessage();
              Timer(
                  const Duration(milliseconds: 100),
                  () => _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent));
            }, // icon of the button
            style: ElevatedButton.styleFrom(
              // styling the button
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.green, // Button color
            ),
            child: const Icon(Icons.arrow_circle_right, color: Colors.white),
          ),
          // send button
        ],
      ),
    );
  }
}
