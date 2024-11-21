import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/model/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home.dart';
import '../auth/welcome_page.dart';
import 'package:http/http.dart' as http;


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  


  // Helper method to show toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Helper method to navigate to home
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const Home(),
      ),
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
    String? username,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String displayName = username?.isNotEmpty == true
          ? username!
          : (email.length >= 5 ? email.substring(0, 5) : email);

      await userCredential.user?.updateDisplayName(displayName);

      // Save user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      _showToast(_getAuthErrorMessage(e));
    } catch (e) {
      _showToast("An unexpected error occurred.");
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      _showToast(_getAuthErrorMessage(e));
    }
  }

  Future<void> signout({required BuildContext context}) async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const WelcomePage()),
      );
    } catch (e) {
      _showToast("Error signing out.");
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _navigateToHome(context);
    } catch (e) {
      _showToast('Failed to sign in with Google.');
    }
  }

  Future<void> addFavoritePost(String postId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePosts': FieldValue.arrayUnion([postId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to add favorite post.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> addFavoritePodcast(String podcastId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePodcasts': FieldValue.arrayUnion([podcastId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to add favorite podcast.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> removeFavoritePost(String postId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePosts': FieldValue.arrayRemove([postId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to remove favorite post.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> removeFavoritePodcast(String podcastId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePodcasts': FieldValue.arrayRemove([podcastId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to remove favorite podcast.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

Future<List<Post>> getFavoritePosts() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Fetch IDs from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<String> postIds = List<String>.from(doc.data()?['favoritePosts'] ?? []);

      // Fetch details from the backend
      List<Post> posts = [];
      for (String postId in postIds) {
        final response = await http.get(
          Uri.parse('https://qyzbolsyn-backend-3.onrender.com/posts/posts/$postId'),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Decode the response using utf8 and map to Post
          Map<String, dynamic> postJson = json.decode(utf8.decode(response.bodyBytes));
          posts.add(Post.fromJson(postJson)); // Use Post model to parse data
        } else {
          throw Exception('Failed to load post with ID: $postId');
        }
      }
      return posts;
    } catch (e) {
      _showToast("Failed to fetch favorite posts.");
      print(e);
    }
  }
  return [];
}


Future<List<Podcast>> getFavoritePodcasts() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Fetch IDs from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<String> podcastIds = List<String>.from(doc.data()?['favoritePodcasts'] ?? []);

      // Fetch details from the backend
      List<Podcast> podcasts = [];
      for (String podcastId in podcastIds) {
        final response = await http.get(
          Uri.parse('https://qyzbolsyn-backend-3.onrender.com/podcasts/podcasts/$podcastId'),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Decode the response using utf8 and map to Podcast
          Map<String, dynamic> podcastJson = json.decode(utf8.decode(response.bodyBytes));
          podcasts.add(Podcast.fromJson(podcastJson)); // Use Podcast model to parse data
        } else {
          throw Exception('Failed to load podcast with ID: $podcastId');
        }
      }
      return podcasts;
    } catch (e) {
      _showToast("Failed to fetch favorite podcasts.");
      print(e);
    }
  }
  return [];
}


  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
