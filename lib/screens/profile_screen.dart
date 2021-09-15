import 'package:flutter/material.dart';
import 'package:velemajstor/model/sharedPreferences.dart';
import 'package:velemajstor/screens/edit_profile_page.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:velemajstor/widgets/profile_widget.dart';
import 'package:velemajstor/model/user.dart' as us;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Profile'),
      body: ListView(physics: BouncingScrollPhysics(), children: [
        ProfileWidget(
            imagePath: UserSharedPreferences.getProfileUrl(),
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            }),
        const SizedBox(height: 24),
        buildName(UserSharedPreferences.getUserName()),
        const SizedBox(height: 48),
        buildAbout(UserSharedPreferences.getAbout()),
      ]),
    );
  }

  Widget buildName(String name) => Column(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            UserSharedPreferences.getUserEmail(),
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildAbout(String about) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
