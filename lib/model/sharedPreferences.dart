import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velemajstor/model/user.dart';

class UserSharedPreferences {
  static SharedPreferences _sharedPreferences;
  static String userNameKey = "USERNAMEKEY";
  static String userIdKey = "USERKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfileUrlKey = "USERPROFILEURLKEY";
  static String userAboutKey = "USERABOUTKEY";
  static User currentUser;
  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveUserName(String userName) async {
    return _sharedPreferences.setString(userNameKey, userName);
  }

  static Future<bool> saveUserId(String userId) async {
    return _sharedPreferences.setString(userIdKey, userId);
  }

  static Future<bool> saveUserEmail(String userEmail) async {
    return _sharedPreferences.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserProfileUrl(String userProfileUrl) async {
    return _sharedPreferences.setString(userProfileUrlKey, userProfileUrl);
  }

  static Future<bool> saveAbout(String userAbout) async {
    return _sharedPreferences.setString(userAboutKey, userAbout);
  }

  static void saveUser(User user) {
    currentUser = user;
  }

  static void saveImage(File image) {
    currentUser.image = image;
  }

  // get data
  static User getUser() {
    return currentUser;
  }

  static File getImage() {
    return currentUser.image;
  }

  static String getUserName() {
    return _sharedPreferences.getString(userNameKey);
  }

  static String getUserId() {
    return _sharedPreferences.getString(userIdKey);
  }

  static String getUserEmail() {
    return _sharedPreferences.getString(userEmailKey);
  }

  static String getProfileUrl() {
    return _sharedPreferences.getString(userProfileUrlKey);
  }

  static String getAbout() {
    return _sharedPreferences.getString(userAboutKey);
  }

  static getChatRoomIdByUsernames(String a, String b) async {
    bool docExists = await checkIfDocExists("$b\_$a");

    if (docExists) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  static Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('chatrooms');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }
}
