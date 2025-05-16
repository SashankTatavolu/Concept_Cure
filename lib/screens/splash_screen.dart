import 'package:chat_bot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:chat_bot/screens/google_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate(); // Step 1: Check for update
  }

  Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Step 2: Perform Flexible or Immediate Update
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      print("Update check failed: $e");
    }

    _checkAuthentication(); // Step 3: Check authentication after update check
  }

  Future<void> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _checkUserDetails(user.uid);
    } else {
      _navigateToAuthScreen();
    }
  }

  Future<void> _checkUserDetails(String userId) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final dataSnapshot =
        await databaseReference.child('User_Information').child(userId).get();

    if (mounted) {
      if (dataSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NextScreen()),
        );
      } else {
        _navigateToAuthScreen();
      }
    }
  }

  void _navigateToAuthScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoogleAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromRGBO(217, 223, 235, 1)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/frame1.png',
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
