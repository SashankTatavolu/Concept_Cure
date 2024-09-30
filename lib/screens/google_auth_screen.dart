// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'language_selection_screen.dart';

class GoogleAuthScreen extends StatelessWidget {
  const GoogleAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading: false,
      ),
      body: Center(
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
                "Sign Up",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                "Stay updated on your learning world",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          "assets/google-logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "Sign Up with Google",
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
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
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

    // Path to the "User_Information" node
    DatabaseReference userRef = database.child('Users/${user.uid}');

    // Check if user data already exists
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      // User exists in the database, navigate to the main screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NextScreen()),
      );
    } else {
      // User doesn't exist, register user in the Realtime Database
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        // Add other relevant fields here
      });

      // Navigate to the main screen after registration
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen()),
      );
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
