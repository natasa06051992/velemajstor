import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:velemajstor/widgets/button_widget.dart';
import 'package:velemajstor/widgets/pickers/user_image_picker.dart';
import 'package:velemajstor/model/user.dart' as us;
import 'package:velemajstor/widgets/auth/auth_form.dart';

class EditProfilePage extends StatefulWidget {
  final us.User user;

  const EditProfilePage(this.user);
  @override
  _EditProfilePageState createState() => _EditProfilePageState(user);
}

class _EditProfilePageState extends State<EditProfilePage> {
  var isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final us.User user;
  _EditProfilePageState(this.user);

  void _trySubmit(BuildContext context) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      _submitAuthForm(
          _userName.trim(),
          _userAbout.trim(),
          //_userImageFile,
          context);
    }
  }

  void _submitAuthForm(
    String username,
    String about,
    // File image,
    BuildContext ctx,
  ) async {
    User authResult = FirebaseAuth.instance.currentUser;
    try {
      authResult.updateDisplayName(username);
      // final ref = FirebaseStorage.instance
      //     .ref()
      //     .child('user_image')
      //     .child(authResult.user.uid + '.jpg');

      // await ref.putFile(image);
      // await ref.getDownloadURL().then((value) {
      FirebaseFirestore.instance.collection('users').doc(authResult.uid).set({
        'username': username,
        // 'url': value,
        'about': about
        //  });
      });
    } on PlatformException catch (e) {
      var message = 'An error occurred, please check your credentials!';
      if (e.message != null) {
        message = e.message;
      }
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    } catch (err) {
      print(err);
    }
  }

  var _userName = '';
  var _userAbout = '';
  File _userImageFile;
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Edit profile'),
      body: Builder(
        builder: (context) => Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            physics: BouncingScrollPhysics(),
            children: [
              UserImagePicker(_pickedImage, user.image),
              const SizedBox(height: 24),
              TextFormField(
                key: ValueKey('username'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                initialValue: user.name,
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) {
                  _userName = value;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: ValueKey('about'),
                initialValue: user.about,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'About',
                ),
                onSaved: (value) {
                  _userAbout = value;
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                  text: 'Save',
                  onClicked: () {
                    _trySubmit(context);
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
