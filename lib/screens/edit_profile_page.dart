import 'package:flutter/material.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:velemajstor/widgets/profile_widget.dart';
import 'package:velemajstor/widgets/textfield_widget.dart';
import 'package:velemajstor/model/user.dart' as us;

class EditProfilePage extends StatefulWidget {
  final us.User user;

  const EditProfilePage(this.user);
  @override
  _EditProfilePageState createState() => _EditProfilePageState(user);
}

class _EditProfilePageState extends State<EditProfilePage> {
  final us.User user;
  _EditProfilePageState(this.user);

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => Scaffold(
          appBar: buildAppBar(context, 'Edit profile'),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            physics: BouncingScrollPhysics(),
            children: [
              ProfileWidget(
                imagePath: user.imagePath,
                isEdit: true,
                onClicked: () async {},
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'Full Name',
                text: user.name,
                onChanged: (name) {},
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'Email',
                text: user.email,
                onChanged: (email) {},
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'About',
                text: user.about,
                maxLines: 5,
                onChanged: (about) {},
              ),
            ],
          ),
        ),
      );
}
