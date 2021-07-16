import 'package:flutter/material.dart';
import 'package:velemajstor/screens/edit_profile_page.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:velemajstor/widgets/profile_widget.dart';
import 'package:velemajstor/model/user.dart' as us;

class ProfileScreen extends StatelessWidget {
  final us.User user;

  const ProfileScreen(this.user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Profile'),
      body: ListView(physics: BouncingScrollPhysics(), children: [
        ProfileWidget(
            imagePath: user.imagePath,
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage(user)),
              );
            }),
        const SizedBox(height: 24),
        buildName(user.name),
        const SizedBox(height: 48),
        buildAbout(user.about),
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
            user.email,
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
