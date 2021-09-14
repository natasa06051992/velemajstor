import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/model/user.dart';
import 'package:velemajstor/screens/chatRoomListTile.dart';
import 'package:velemajstor/screens/chat_screen.dart';
import 'package:velemajstor/widgets/app_bar.dart';

class ChatRoom extends StatefulWidget {
  final User user;

  const ChatRoom(this.user);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String myUsername, myProfilePic, myUserName, myEmail, chatRoomId;
  User chatWithUser;
  TextEditingController searchUsernameEditingController =
      TextEditingController();
  Stream usersStream, chatRoomsStream;
  bool isSearching = false;
  Future<Stream<QuerySnapshot>> getChatRoomsInFirebase() async {
    var t = FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", arrayContains: myUsername)
        .orderBy("lastMessageSendTs", descending: true);
    return t?.snapshots();
  }

  getMyInfoFromSharedPreference() async {
    myProfilePic = widget.user.imagePath;
    myUserName = widget.user.name;
    myEmail = widget.user.email;

    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    await getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
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
                  if (ds.id.toString().contains(widget.user.id)) {
                    return ChatRoomListTile(
                        ds["lastMessage"], ds.id, widget.user);
                  } else {
                    return Container();
                  }
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('username', isNotEqualTo: widget.user.name)
        .where('username',
            isGreaterThanOrEqualTo: searchUsernameEditingController.text)
        .where('username',
            isLessThan: searchUsernameEditingController.text + 'z')
        .snapshots();
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
                      profileUrl: ds["url"],
                      email: ds["email"],
                      username: ds["username"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getChatRoomIdByUsernames(String a, String b) async {
    bool docExists = await checkIfDocExists("$b\_$a");
    print("Document exists in Firestore? " + docExists.toString());
    if (docExists) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  /// Check If Document Exists
  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('chatrooms');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
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

  Future<User> getUserInfo(String username) async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get()
        .then((value) {
      chatWithUser = User(
        id: value.docs[0].id,
        about: value.docs[0]["about"],
        email: value.docs[0]["email"],
        imagePath: value.docs[0]["url"],
        name: value.docs[0]["username"],
      );
    });
    return chatWithUser;
  }

  Widget searchListUserTile({String profileUrl, username, email}) {
    User chatWithUser;

    return GestureDetector(
      onTap: () {
        getUserInfo(username).then((value) async {
          chatWithUser = value;
          chatRoomId =
              await getChatRoomIdByUsernames(chatWithUser.id, widget.user.id);
          Map<String, dynamic> chatRoomInfoMap = {
            "users": [myUserName, username]
          };
          createChatRoomInFirebase(chatRoomId, chatRoomInfoMap);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(chatWithUser, widget.user)));
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profileUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(username), Text(email)])
          ],
        ),
      ),
    );
  }

  getChatRooms() async {
    chatRoomsStream = await getChatRoomsInFirebase();
    setState(() {});
  }

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
}
