import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/model/sharedPreferences.dart';
import 'package:velemajstor/screens/chatRoom.dart';
import 'package:velemajstor/screens/profile_screen.dart';
import 'package:velemajstor/model/user.dart' as us;
import 'package:velemajstor/widgets/auth/auth_form.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> pages;
  bool isLoading = true;
  static us.User currentUser;
  @override
  void initState() {
    getImage().then((value) {
      getAbout(user.uid);
      currentUser = us.User(
        id: user.uid,
        imagePath: user.photoURL,
        about: about,
        name: user.displayName,
        email: user.email,
        image: value,
      );
      pages = [
        {'page': ChatRoom(), 'title': 'Chat'},
        {'page': ProfileScreen(), 'title': 'Profile'},
      ];
      setState(() {
        isLoading = false;
      });
      UserSharedPreferences.saveAbout(about);
      UserSharedPreferences.saveUser(currentUser);
      UserSharedPreferences.saveUserEmail(user.email);
      UserSharedPreferences.saveUserId(user.uid);
      UserSharedPreferences.saveUserName(user.displayName);
      UserSharedPreferences.saveUserProfileUrl(user.photoURL);
    });

    // TODO: implement initState
    super.initState();
  }

  String about = '';
  void getAbout(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) => about = value['about']);
  }

  final user = FirebaseAuth.instance.currentUser;
  File imageOfUser;
  Future<File> getImage() async {
    return await AuthFormState.urlToFile(user.photoURL);
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pages[_selectedPageIndex]['page'],
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
