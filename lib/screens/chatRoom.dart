import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/model/sharedPreferences.dart';
import 'package:velemajstor/model/user.dart';
import 'package:velemajstor/screens/chatRoomListTile.dart';
import 'package:velemajstor/screens/chat_screen.dart';
import 'package:velemajstor/widgets/app_bar.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom();
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String chatRoomId;
  User chatWithUser;
  bool isSearching = false;
  TextEditingController searchUsernameEditingController =
      TextEditingController();
  Stream usersStream, chatRoomsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Chat room'),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = "";
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 1.4),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchUsernameEditingController,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "username"),
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingController.text != "") {
                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: isSearching ? searchUsersList() : chatRoomsList())
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  onScreenLoaded() async {
    await getChatRooms();
  }

  getChatRooms() async {
    chatRoomsStream = await getChatRoomsFromFirebase();
    setState(() {});
  }

  Future<Stream<QuerySnapshot>> getChatRoomsFromFirebase() async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .where("chatUsers", arrayContains: UserSharedPreferences.getUserId())
        .orderBy("lastMessageSendTs", descending: true)
        .snapshots();
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData && chatRoomsStream != null
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data?.docs[index];
                  if (ds.id
                      .toString()
                      .contains(UserSharedPreferences.getUserId())) {
                    var uid = ds.id
                        .replaceAll(UserSharedPreferences.getUserId(), "")
                        .replaceAll("_", "");

                    return ChatRoomListTile(ds["lastMessage"], uid);
                  } else {
                    return Container();
                  }
                })
            : Center();
      },
    );
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});

    // usersStream = FirebaseFirestore.instance
    //     .collection('users')
    //     .where('username', isNotEqualTo: UserSharedPreferences.getUserName())
    //     .where('username',
    //         isGreaterThanOrEqualTo: searchUsernameEditingController.text)
    //     .where('username',
    //         isLessThan: searchUsernameEditingController.text + 'z')
    //     .snapshots();
    var query = FirebaseFirestore.instance.collection('users');
    var query1 = query.where('username',
        isNotEqualTo: UserSharedPreferences.getUserName());
    var query2 = query1.where('username',
        isGreaterThanOrEqualTo: searchUsernameEditingController.text);
    var query3 = query2.where('username',
        isLessThan: searchUsernameEditingController.text + 'z');
    usersStream = query3.snapshots();
    setState(() {});
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      chatWithUserProfileUrl: ds["url"],
                      chatWithUserEmail: ds["email"],
                      chatWithUserUsername: ds["username"],
                      chatWithUserId: ds.id);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  createChatRoomInFirebase(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<User> getUserInfo(String chatWithUserId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(chatWithUserId)
        .get()
        .then((value) {
      chatWithUser = User(
        id: value.id,
        about: value["about"],
        email: value["email"],
        imagePath: value["url"],
        name: value["username"],
      );
    });
    return chatWithUser;
  }

  Widget searchListUserTile(
      {String chatWithUserProfileUrl,
      chatWithUserEmail,
      chatWithUserUsername,
      chatWithUserId}) {
    User chatWithUser;

    return GestureDetector(
      onTap: () {
        getUserInfo(chatWithUserId).then((value) async {
          chatWithUser = value;
          chatRoomId = await UserSharedPreferences.getChatRoomIdByUsernames(
              chatWithUser.id, UserSharedPreferences.getUserId());
          Map<String, dynamic> chatRoomInfoMap = {
            "chatUsers": [UserSharedPreferences.getUserId(), chatWithUserId]
          };
          createChatRoomInFirebase(chatRoomId, chatRoomInfoMap);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(chatWithUser)));
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                chatWithUserProfileUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(chatWithUserUsername), Text(chatWithUserEmail)])
          ],
        ),
      ),
    );
  }
}
