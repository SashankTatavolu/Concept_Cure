// // ignore_for_file: use_key_in_widget_constructors

// import 'package:flutter/material.dart';
// import 'package:chat_bot/screens/language_selection_screen.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LanguageSelectionScreen(),
//         ),
//       );
//     });

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Image.asset(
//                     'assets/frame1.png',
//                     width: double.infinity, // Occupy entire
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_bot/screens/language_selection_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      // Check if user is authenticated and all details are filled
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          await checkUserDetails(user.uid, context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen(),
            ),
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/frame1.png',
              width: double.infinity, // Use 80% of the device width
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> checkUserDetails(String userId, BuildContext context) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final dataSnapshot =
        await databaseReference.child('User_Information').child(userId).once();

    // Check if user details are filled
    if (dataSnapshot.snapshot.value != null) {
      // Redirect to the next screen
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>
              const NextScreen(), // Replace with your next screen
        ),
      );
    } else {
      // Redirect user to fill details screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LanguageSelectionScreen(), // Replace with your fill details screen
        ),
      );
    }
  }
}
