import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthManager with ChangeNotifier {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final List<String> allowedUsersEmails = [];

  static final ChangeNotifier allowedUsersNotifier = ChangeNotifier();
  static final ChangeNotifier currentUserNotifier = ChangeNotifier();

  static User? currentUser;
  static String? get userName => currentUser?.displayName;
  static set userName(String? newUsername) => updateUserName(newUsername);
  static String? get userEmail => currentUser?.email;

  static bool get loggedIn => currentUser != null;

  static void updateUserName(String? newUsername) async {
    if (kDebugMode) {
      print("Update UserName to: $newUsername");
    }
    await currentUser?.updateDisplayName(newUsername);
    await fetchUser();
    if (kDebugMode) {
      print("Result: $userName");
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await fetchUser();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Login failed: $e');
      }
      return false;
    }
  }

  static void fetchAllowedUsers() {
    FirebaseFirestore.instance
        .collection("config")
        .doc("allowed_users")
        .snapshots()
        .listen((DocumentSnapshot snapShot) {
      if (snapShot.exists) {
        Map<String, dynamic> data = snapShot.data() as Map<String, dynamic>;

        if (data.containsKey("user_emails")) {
          List<String> fetchedAllowedUsers =
              List<String>.from(data["user_emails"]);
          allowedUsersEmails.clear();
          allowedUsersEmails.addAll(fetchedAllowedUsers);
          if (kDebugMode) {
            print("Allowed User IDs: $allowedUsersEmails");
          }
          allowedUsersNotifier.notifyListeners();
        } else {
          if (kDebugMode) {
            print("user_emails key not found in the document data!");
          }
        }
      } else {
        if (kDebugMode) {
          print("Document does not exist!");
        }
      }
    });
  }

  static Future<void> removeUserPermissions(String userId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("config").doc("allowed_users");
    DocumentSnapshot docSnap = await docRef.get();
    if (docSnap.exists) {
      Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
      if (data.containsKey("user_emails")) {
        List<String> userIds = List<String>.from(data["user_emails"]);
        userIds.remove(userId);
        await docRef.update({"user_emails": userIds});
      }
    }
  }

  static Future<void> addUserPermissions(String userId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("config").doc("allowed_users");
    DocumentSnapshot docSnap = await docRef.get();
    if (docSnap.exists) {
      Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
      if (data.containsKey("user_emails")) {
        List<String> userIds = List<String>.from(data["user_emails"]);
        if (!userIds.contains(userId)) {
          userIds.add(userId);
          await docRef.update({"user_emails": userIds});
        }
      } else {
        await docRef.set({
          "user_emails": [userId]
        });
      }
    } else {
      await docRef.set({
        "user_emails": [userId]
      });
    }
  }

  static bool isUserAllowed() {
    return allowedUsersEmails.contains(currentUser?.email);
  }

  static Future<void> logout() async {
    currentUser = null;
    await firebaseAuth.signOut();
  }

  static Future<void> fetchUser() async {
    currentUser = firebaseAuth.currentUser;
    currentUserNotifier.notifyListeners();
  }

  static Future<void> init() async {
    await fetchUser();
    AuthManager.fetchAllowedUsers();
  }
}
