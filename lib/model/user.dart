import 'dart:io';

import 'package:flutter/material.dart';

class User {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  final String id;
  File image;

  set setImage(File imageE) {
    image = imageE;
  }

  User({
    @required this.imagePath,
    @required this.name,
    @required this.email,
    @required this.about,
    @required this.id,
    this.image,
  });
}
