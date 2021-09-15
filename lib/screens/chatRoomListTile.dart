import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/model/user.dart';
import 'package:velemajstor/screens/chat_screen.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage;
  final String id;
  ChatRoomListTile(this.lastMessage, this.id);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  Future<DocumentSnapshot> getUserInfo(String uid) {
    return FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection("users").doc(widget.id).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var chatWithUser = User(
              id: snapshot.data.id,
              about: snapshot.data["about"],
              email: snapshot.data["email"],
              imagePath: snapshot.data["url"],
              name: snapshot.data["username"],
            );
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(chatWithUser)));
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: chatWithUser != null
                          ? Image.network(
                              chatWithUser.imagePath,
                              height: 40,
                              width: 40,
                            )
                          : Container(),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatWithUser != null ? chatWithUser.name : "",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 3),
                        Text(widget.lastMessage)
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
