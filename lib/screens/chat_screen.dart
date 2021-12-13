import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velemajstor/model/sharedPreferences.dart';
import 'package:velemajstor/model/user.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final User chatWithUser;
  ChatScreen(this.chatWithUser);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId, messageId;
  Stream messageStream;
  TextEditingController messageTextEdittingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    chatRoomId = await UserSharedPreferences.getChatRoomIdByUsernames(
        widget.chatWithUser.id, UserSharedPreferences.getUserId());
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"],
                      UserSharedPreferences.getUserName() == ds["sendBy"],
                      ds["ts"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget chatMessageTile(String message, bool sendByMe, Timestamp timestemp) {
    final f = new DateFormat('yyyy-MM-dd hh:mm');
    return Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
              child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight:
                          sendByMe ? Radius.circular(0) : Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft:
                          sendByMe ? Radius.circular(24) : Radius.circular(0),
                    ),
                    color: sendByMe ? Colors.purple : Colors.grey),
                padding: EdgeInsets.all(16),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(f.format(timestemp.toDate())),
            ],
          )),
        ]);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  getAndSetMessages() async {
    messageStream = await getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
    await getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  addMessage() {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": UserSharedPreferences.getUserName(),
        "ts": lastMessageTs,
        "imgUrl": UserSharedPreferences.getProfileUrl()
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      addMessageInFirebase(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": UserSharedPreferences.getUserId()
        };

        updateLastMessageSendInFirebase(chatRoomId, lastMessageInfoMap);

        messageTextEdittingController.text = "";
        messageId = "";
        getAndSetMessages();
      });
    }
  }

  updateLastMessageSendInFirebase(String chatRoomId, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future addMessageInFirebase(
      String chatRoomId, String messageId, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.chatWithUser.name),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTextEdittingController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "type a message",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.6))),
                    )),
                    GestureDetector(
                      onTap: () {
                        showAttachmentBottomSheet(context);
                      },
                      child: Icon(
                        Icons.attachment,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Image'),
                    onTap: () => showFilePicker(FileType.image)),
                ListTile(
                    leading: Icon(Icons.videocam),
                    title: Text('Video'),
                    onTap: () => showFilePicker(FileType.video)),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('File'),
                  onTap: () => showFilePicker(FileType.any),
                ),
              ],
            ),
          );
        });
  }

  showFilePicker(FileType fileType) async {
    File file = await FilePicker.getFile(type: fileType);
    //sendFileToFireBaseStorage(file, fileType);
    Navigator.pop(context);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Sending attachment..'),
      backgroundColor: Theme.of(context).primaryColor,
    ));
  }

  sendFileToFireBaseStorage(File file, FileType fileType) async {
    var ref = FirebaseStorage.instance.ref().child('chat_files').child(
        chatRoomId +
            '_' +
            DateTime.now().microsecondsSinceEpoch.toString() +
            '_' +
            file.path +
            fileType.toString());
    await ref.putFile(file).whenComplete(() => ref.getDownloadURL());
  }
}
