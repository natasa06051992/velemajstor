import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velemajstor/model/user.dart';
import 'package:http/http.dart' as http;

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

  static Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }
}
