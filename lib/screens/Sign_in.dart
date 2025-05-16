// ignore_for_file: avoid_print, file_names, use_build_context_synchronously, library_private_types_in_public_api

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:chat_bot/screens/language_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50), // Add top padding
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Stay updated on your learning world',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // Implement Forgot Password functionality
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement login functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(20),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _signInWithGoogle(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withOpacity(0.7)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset(
                              "assets/google-logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            "Sign In with Google",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(0, 0, 0, 0.54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        // Sign in to Firebase with Google credentials
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Check if the user exists in the Realtime Database
        await _checkUserInRealtimeDatabase(userCredential.user!, context);
      } else {
        _showErrorDialog(context, "Sign in failed. Please try again.");
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      _showErrorDialog(context, "Sign in failed. Please try again.");
    }
  }

  Future<void> _checkUserInRealtimeDatabase(
      User user, BuildContext context) async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    // Path to the "Users" node
    DatabaseReference userRef = database.child('Users/${user.uid}');

    try {
      // Check if user data already exists
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        // Debug log
        print("User exists in database: ${user.uid}");

        // Navigate to the main screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NextScreen()),
        );
      } else {
        // Debug log
        print("New user, adding to database: ${user.uid}");

        // User doesn't exist, register user in the Realtime Database
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          // Add other relevant fields here
        });

        // Navigate to the language selection screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen()),
        );
      }
    } catch (e) {
      // Log and show error dialog
      print("Error in checking user in database: $e");
      _showErrorDialog(context, "An error occurred. Please try again.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
