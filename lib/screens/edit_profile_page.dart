import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velemajstor/model/sharedPreferences.dart';
import 'package:velemajstor/widgets/app_bar.dart';
import 'package:velemajstor/widgets/button_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage();
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var isLoading = false;
  final _formKey = GlobalKey<FormState>();
  _EditProfilePageState();

  void _trySubmit(BuildContext context) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      _submitAuthForm(_userName.trim(), _userAbout.trim(),
          UserSharedPreferences.getImage(), context);
    }
  }

  void _submitAuthForm(
    String username,
    String about,
    File image,
    BuildContext ctx,
  ) async {
    User authResult = FirebaseAuth.instance.currentUser;
    try {
      authResult.updateDisplayName(username);

      UserSharedPreferences.saveAbout(about);
      UserSharedPreferences.saveUserName(username);
      //UserSharedPreferences.saveImage(image);

      var ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(authResult.uid + '.jpg');
      await ref.putFile(image);
      await ref.getDownloadURL().then((value) {
        UserSharedPreferences.saveUserProfileUrl(value);
        FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.uid)
            .update({'username': username, 'url': value, 'about': about});
      });
      // setState(() {});
      // Navigator.of(context).pop();
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

  var imagePicker = ImagePicker();
  File pickedFile;
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
              Center(
                child: Stack(children: [
                  ClipOval(
                      child: Image.file(
                    UserSharedPreferences.getImage(),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )),
                  Positioned(
                      bottom: 10,
                      right: 23,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: ((builder) => bottomSheet()));
                        },
                        child: Icon(Icons.camera_alt,
                            size: 30, color: Colors.purple),
                      ))
                ]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: ValueKey('username'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                initialValue: UserSharedPreferences.getUserName(),
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) {
                  _userName = value;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: ValueKey('about'),
                initialValue: UserSharedPreferences.getAbout(),
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

  void takePhoto(ImageSource source) async {
    pickedFile = await ImagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        UserSharedPreferences.saveImage(pickedFile);
      }
    });
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(children: [
        Text(
          'Choose profile picture',
        ),
        SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          FlatButton.icon(
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              icon: Icon(Icons.camera, color: Colors.deepPurple),
              label: Text(
                'Camera',
                style: TextStyle(color: Colors.deepPurple),
              )),
          FlatButton.icon(
            onPressed: () {
              takePhoto(ImageSource.gallery);
            },
            icon: Icon(Icons.image, color: Colors.deepPurple),
            label: Text(
              'Gallery',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ]),
      ]),
    );
  }
}
