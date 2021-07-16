import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/screens/chat_screen.dart';
import 'package:velemajstor/screens/profile_screen.dart';
import 'package:velemajstor/model/user.dart' as us;

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

String about = 'Nati';
void getAbout(String uid) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value) => about = value['about']);
}

class _TabsScreenState extends State<TabsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  List<Map<String, Object>> pages;

  @override
  void initState() {
    getAbout(user.uid);
    pages = [
      {'page': ChatScreen(), 'title': 'Chat'},
      {
        'page': ProfileScreen(us.User(
            imagePath: user.photoURL,
            about: about,
            name: user.displayName,
            email: user.email)),
        'title': 'Profile'
      },
    ];
    // TODO: implement initState
    super.initState();
  }

  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              title: Text('Chat')),
          BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: Text('Profile')),
        ],
      ),
    );
  }
}
