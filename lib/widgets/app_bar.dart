import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velemajstor/screens/auth_screen.dart';

PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    actions: [
      GestureDetector(
        onTap: () {
          FirebaseAuth.instance.signOut();
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => AuthScreen()));
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Logout'),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.exit_to_app),
              ],
            )),
      )
    ],
  );
}
