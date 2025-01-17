import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/model/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
    // Sign out from Firebase and other providers (e.g., Google Sign-In)
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);

    // Clear user data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored data, including isLoggedIn and userId

    // Navigate to the Welcome Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  } catch (e) {
    // Show a toast message in case of an error
    _showToast("Ошибка при выходе из системы. Пожалуйста, попробуйте еще раз.");
  }
}

  // Apple Sign-In Method
Future<void> signInWithApple(BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // Save the login state in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userCredential.user!.uid);

    // Check if the user exists in Firestore
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user if not found
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': appleCredential.email ?? userCredential.user!.email ?? '',
        'displayName': appleCredential.givenName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : 'Apple User',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Navigate to the Home page
    _navigateToHome(context);
  } catch (e) {
    _showToast('Не удалось войти с помощью Apple.');
  }
}


Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      _showToast('Вход через Google был отменен.');
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // Save the login state in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userCredential.user!.uid);

    // Check if the user exists in Firestore
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user if not found
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName ?? 'Google User',
        'photoURL': userCredential.user!.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Navigate to the Home page
    _navigateToHome(context);
  } on FirebaseAuthException catch (e) {
    _showToast('Аутентификация не выполнена:${_getAuthErrorMessage(e)}');
  } catch (e) {
    _showToast('Не удалось войти с помощью Google.Попробуйте еще раз.');
  }
}


Future<void> registerUserWithGoogle(BuildContext context) async {
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

    // Check if the user already exists
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName ?? 'Google User',
        'photoURL': userCredential.user!.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _navigateToHome(context);
  } catch (e) {
    _showToast('Не удалось зарегистрироваться с помощью Google.');
    print(e);
  }
}

Future<void> registerUserWithApple(BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Check if the user already exists
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': appleCredential.email ?? '',
        'displayName': appleCredential.givenName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : 'Apple User',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _navigateToHome(context);
  } catch (e) {
    _showToast('Не удалось зарегистрироваться с помощью Apple.');
    print(e);
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
        _showToast("Не удалось добавить пост в избранное.");
      }
    } else {
      _showToast("Вы должны войти в систему, чтобы выполнить это действие.");
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
        _showToast("Не удалось удалить подкаст из избранного.");
      }
    } else {
      _showToast("Вы должны войти в систему, чтобы выполнить это действие.");
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
        _showToast("Не удалось добавить подкаст в избранное.");
      }
    } else {
      _showToast("Вы должны войти в систему, чтобы выполнить это действие.");
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
        _showToast("Не удалось удалить пост из избранного.");
      }
    } else {
      _showToast("Вы должны войти в систему, чтобы выполнить это действие.");
    }
  }

Future<List<Post>> getFavoritePosts() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<String> postIds = List<String>.from(doc.data()?['favoritePosts'] ?? []);
      List<Post> posts = [];

      for (String postId in postIds) {
        final response = await http.get(
          Uri.parse('https://qyzbolsyn-backend-j2rg.onrender.com/posts/posts/$postId'),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> postJson = json.decode(utf8.decode(response.bodyBytes));
          posts.add(Post.fromJson(postJson));
        } else if (response.statusCode == 404) {
          // Automatically remove this nonexistent Post from Firestore
          await removeFavoritePost(postId);
          debugPrint('Post with ID: $postId does not exist on the server. Removing from favorites...');
        } else {
          debugPrint('Failed to load post with ID: $postId (HTTP ${response.statusCode}). Skipping...');
        }
      }

      return posts;
    } catch (e) {
      _showToast("Не удалось загрузить избранные посты.");
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
          Uri.parse('https://qyzbolsyn-backend-j2rg.onrender.com/podcasts/podcasts/$podcastId'),
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
      _showToast("Не удалось загрузить избранные подкасты.");
      print(e);
    }
  }
  return [];
}


Future<void> resetPassword({
  required String email,
  required BuildContext context,
}) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    _showToast('Ссылка для сброса пароля была отправлена на $email.');
  } on FirebaseAuthException catch (e) {
    _showToast(_getAuthErrorMessage(e));
  } catch (e) {
    _showToast('Произошла непредвиденная ошибка. Пожалуйста, попробуйте еще раз.');
  }
}

Future<void> deleteAccount(BuildContext context) async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Delete the user's Firestore document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account from Firebase Authentication
      await user.delete();

      // Show a success message
      _showToast("Ваш аккаунт был успешно удален.");

      // Navigate to the Welcome page after deletion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showToast("Пожалуйста, войдите в систему снова, чтобы удалить свой аккаунт.");
      } else {
        _showToast("Произошла ошибка при удалении аккаунта.");
      }
    } catch (e) {
      _showToast("Произошла непредвиденная ошибка. Пожалуйста, попробуйте еще раз.");
    }
  } else {
    _showToast("Пользователь не вошел в систему.");
  }
}

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
        case 'weak-password':
          return 'Предоставленный пароль слишком слабый.';
        case 'email-already-in-use':
          return 'Аккаунт с таким email уже существует.';
        case 'invalid-email':
          return 'Неверный адрес электронной почты.';
        case 'operation-not-allowed':
          return 'Вход через Google не включен.';
        case 'invalid-credential':
          return 'Недействительные учетные данные.';
        case 'user-disabled':
          return 'Этот аккаунт был отключен.';
        case 'user-not-found':
          return 'Пользователь с таким email не найден.';
        case 'wrong-password':
          return 'Указан неверный пароль.';
        case 'account-exists-with-different-credential':
          return 'Аккаунт с таким email уже существует, но с другими учетными данными.';
        default:
          return 'Произошла ошибка. Пожалуйста, попробуйте еще раз.';
    }
  }
}
