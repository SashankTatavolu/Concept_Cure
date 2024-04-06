// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:chat_bot/screens/registration_screen.dart';

// class GoogleAuthScreen extends StatefulWidget {
//   const GoogleAuthScreen({super.key});

//   @override
//   State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
// }

// class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.6,
//           width: MediaQuery.of(context).size.width * 0.8,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 4,
//                 blurRadius: 8,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Sign Up",
//                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
//               ),
//               const Text(
//                 "Stay updated on your learning world",
//                 style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 width: 350,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey.withOpacity(0.7)),
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(
//                       width: 40,
//                     ),
//                     SizedBox(
//                       width: 50,
//                       height: 50,
//                       child: Image.asset(
//                         "assets/google-logo.png",
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     GestureDetector(
//                       child: const Text(
//                         "Sign Up with Google",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: Color.fromRGBO(0, 0, 0, 0.54),
//                         ),
//                       ),
//                       onTap: () {
//                         _signInWithGoogle();
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   _signInWithGoogle() async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();

//     try {
//       final GoogleSignInAccount? googleSignInAccount =
//           await googleSignIn.signIn();
//       if (googleSignInAccount != null) {
//         final GoogleSignInAuthentication googleSignInAuthentication =
//             await googleSignInAccount.authentication;

//         final AuthCredential credential = GoogleAuthProvider.credential(
//           idToken: googleSignInAuthentication.idToken,
//           accessToken: googleSignInAuthentication.accessToken,
//         );

//         await _firebaseAuth.signInWithCredential(credential);
//         Navigator.push(
//           // ignore: use_build_context_synchronously
//           context,
//           MaterialPageRoute(builder: (context) => const RegistrationScreen()),
//         );
//       }
//       // ignore: empty_catches
//     } catch (e) {}
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_bot/screens/registration_screen.dart';

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

  void _signInWithGoogle(BuildContext context) async {
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

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error signing in with Google: $e");
    }
  }
}
