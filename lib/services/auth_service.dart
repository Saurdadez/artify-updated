// ignore_for_file: use_build_context_synchronously

import 'package:art_app/models/user_model.dart';
import 'package:art_app/services/utils.dart';
// ignore: library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthPackage;
import 'package:art_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuthPackage.FirebaseAuth _auth =
      FirebaseAuthPackage.FirebaseAuth.instance;
  final FirestoreService _store = FirestoreService();

  Future<FirebaseAuthPackage.UserCredential?> registerWithEmail(
      UserObject user, String password) async {
    try {
      FirebaseAuthPackage.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      await _store.createUser(user);
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<void> signUserIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String?> getCurrentUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      return user.email;
    } else {
      return null;
    }
  }

  Future<bool> isUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    return user != null;
  }

  Future<String> registerWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    String username = Utils.generateRandomUsername();
    List<String> interest = ['Painting'];
    try {
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final currentUser = userCredential.user;

        bool userExists = await _store.doesUserExist(currentUser?.email ?? '');
        if (!userExists) {
          String? firstName = gUser.displayName?.split(" ").first ?? 'N/A';
          String? lastName = gUser.displayName?.split(" ").last ?? 'N/A';
          String? profileUrl = gUser.photoUrl ?? 'N/A';
          String? country = 'N/A';
          if (!profileUrl.contains('N/A')) {
            profileUrl = await FirestoreService()
                .uploadImageToFirebase(profileUrl, 'profileurls');
          }

          UserObject newUser = UserObject(
            dateCreated: Utils.getCurrentTime(),
            firstName: firstName,
            lastName: lastName,
            profileUrl: profileUrl,
            userFavorites: [],
            userLiked: [],
            followers: [],
            following: [],
            email: currentUser!.email ?? 'N/A',
            username: username,
            interests: interest,
            commissions: [],
            contactNumber: 'N/A',
            streetAddress: 'N/A',
            cityAddress: 'N/A',
            zip: 'N/A',
            country: country,
            credits: 0.0,
          );
          await _store.createUser(newUser);

          return 'Registered successfully';
        }
      } else {
        return 'Google sign-in was cancelled.';
      }
    } catch (e) {
      return 'Error signing in with Google: $e';
    }
    return '';
  }

  void logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    try {
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser != null) {
        final doesExist = await FirestoreService().doesUserExist(gUser.email);
        if (!doesExist) {
          registerWithGoogle();
        }
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        await firebaseAuth.signInWithCredential(credential);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
