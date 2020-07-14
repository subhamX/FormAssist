import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;
  static final _googleSignIn = GoogleSignIn();

  // Sign Up User Using Email And Password
  static Future signUp(Map<String, String> data, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return LoadingBox();
          });
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: data['email'], password: data['password']);
      FirebaseUser signedInUser = result.user;
      // Adding Data To CloudFirestore
      if (result.additionalUserInfo.isNewUser) {
        if (signedInUser != null) {
          await signedInUser.sendEmailVerification();
          await _firestore
              .collection('/users')
              .document(signedInUser.uid)
              .setData({
            'name': data['name'],
            'email': data['email'],
            'signup_timestamp': DateTime.now(),
          });
          await _firestore
              .collection('forms')
              .document(signedInUser.uid)
              .setData({'user_email': data['email']});
          await _firestore
              .collection('links')
              .document(signedInUser.uid)
              .setData({"email": signedInUser.email});
          // Navigating To Home
          if (!result.user.isAnonymous) {
            Navigator.pushReplacementNamed(context, 'home');
          }
        }
      } else {
        Navigator.pop(context);
      }
    } catch (err) {
      print(err);
      Flushbar(
        message: "Email Already In Use",
        duration: Duration(milliseconds: 600),
      ).show(context);
      await Future.delayed(Duration(milliseconds: 700));
      Navigator.pop(context);
    }
  }

  // Sign In User Using Email And Password
  static Future signIn(Map<String, String> data, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return LoadingBox();
          });
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: data['email'], password: data['password']);
      FirebaseUser user = result.user;
      if (result.additionalUserInfo.isNewUser) {
        await _firestore.collection('users').document(user.uid).setData({
          'name': user.displayName,
          'email': user.email,
          'last_signin_timestamp': DateTime.now(),
        });
        await _firestore
            .collection('forms')
            .document(user.uid)
            .setData({'user_email': user.email});
        await _firestore
            .collection('links')
            .document(user.uid)
            .setData({"email": user.email});
      } else {
        await _firestore.collection('users').document(user.uid).updateData({
          'last_signin_timestamp': DateTime.now(),
        });
      }
      if (!user.isAnonymous) {
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (err) {
      Flushbar(
        message: "Incorrect Email or Password!",
        duration: Duration(seconds: 1),
      ).show(context);
      await Future.delayed(Duration(seconds: 1, milliseconds: 100));
      Navigator.pop(context);

      print(err);
    }
  }

  // Handles Forgot Password
  static Future forgotPassword(
      Map<String, String> data, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingBox();
        });
    try {
      await _auth.sendPasswordResetEmail(email: data["email"]);
    } catch (err) {
      print('Error Occured! $err');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(),
        ),
      );
    }
    Flushbar(
      message: "Password Reset Link Sent!",
      duration: Duration(seconds: 1),
    ).show(context);
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
  }

  // Signs In User using Google Auth
  static Future googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final AuthResult result = await _auth.signInWithCredential(credential);
      final FirebaseUser user = result.user;
      if (result.additionalUserInfo.isNewUser) {
        await _firestore.collection('users').document(user.uid).setData({
          'name': user.displayName,
          'email': user.email,
          'last_seen': DateTime.now(),
        });
        await _firestore
            .collection('forms')
            .document(user.uid)
            .setData({'user_email': user.email});
        await _firestore
            .collection('links')
            .document(user.uid)
            .setData({"email": user.email});
      } else {
        await _firestore.collection('users').document(user.uid).updateData({
          'last_seen': DateTime.now(),
        });
      }

      if (!user.isAnonymous) {
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (err) {
      print(err);
    }
  }

  // Method Handles Sign Out Event
  static void signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, 'signin');
    } catch (err) {
      print(err);
    }
  }
}
