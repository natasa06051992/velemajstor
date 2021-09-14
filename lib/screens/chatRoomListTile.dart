import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/model/user.dart';
import 'package:velemajstor/screens/chat_screen.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId;
  final User user;

  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.user);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String uid = "";
  User chatWithUser;
  getThisUserInfo() async {
    uid = widget.chatRoomId.replaceAll(widget.user.id, "").replaceAll("_", "");
    var document = await getUserInfo(uid);

    chatWithUser = User(
      id: document.id,
      about: document["about"],
      email: document["email"],
      imagePath: document["url"],
      name: document["username"],
    );

    setState(() {});
  }

  Future<DocumentSnapshot> getUserInfo(String uid) async {
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(chatWithUser, widget.user)));
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
  }
}
