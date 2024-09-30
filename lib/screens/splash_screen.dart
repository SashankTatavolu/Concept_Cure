// import 'package:chat_bot/screens/chat_screen.dart';
// import 'package:chat_bot/screens/google_auth_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 3), () {
//       FirebaseAuth.instance.authStateChanges().listen((User? user) async {
//         bool updateRequired = await checkForUpdate(context);

//         if (!updateRequired) {
//           if (user != null) {
//             await checkUserDetails(user.uid, context);
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const GoogleAuthScreen(),
//               ),
//             );
//           }
//         }
//       });
//     });

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/frame1.png',
//               width: double.infinity,
//               fit: BoxFit.fill,
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> checkUserDetails(String userId, BuildContext context) async {
//     final databaseReference = FirebaseDatabase.instance.ref();
//     final dataSnapshot =
//         await databaseReference.child('User_Information').child(userId).get();

//     if (dataSnapshot.exists) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               const NextScreen(), // Replace with your next screen
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               const GoogleAuthScreen(), // Replace with your fill details screen
//         ),
//       );
//     }
//   }

//   Future<bool> checkForUpdate(BuildContext context) async {
//     try {
//       final databaseReference = FirebaseDatabase.instance.ref();
//       final dataSnapshot =
//           await databaseReference.child('app_config/required_version').get();

//       if (dataSnapshot.exists) {
//         final requiredVersion = dataSnapshot.value as String?;
//         print('Required version from Firebase: $requiredVersion');

//         final packageInfo = await PackageInfo.fromPlatform();
//         final currentVersion = packageInfo.version;
//         print('Current app version: $currentVersion');

//         if (requiredVersion != null && requiredVersion != currentVersion) {
//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (context) => AlertDialog(
//               title: const Text('Update Required'),
//               content: const Text(
//                   'A new version of the app is available. Please update to continue.'),
//               actions: [
//                 TextButton(
//                   onPressed: () async {
//                     final url = Uri.parse(
//                         'https://drive.google.com/uc?export=download&id=1yo-j3jOQhumf_dcYVbtVS5-y4MHfDIGg');
//                     if (await canLaunchUrl(url)) {
//                       await launchUrl(url);
//                     } else {
//                       print('Could not launch $url');
//                     }
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('Update'),
//                 ),
//               ],
//             ),
//           );

//           return true;
//         }
//       } else {
//         print('Failed to fetch required version from Firebase.');
//       }
//     } catch (e) {
//       print('Error checking for update: $e');
//     }

//     return false;
//   }
// }

// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:chat_bot/screens/google_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    final defaultConfig = {
      'required_version': '1.0.0', // Replace with your initial version
      'update_url':
          'https://your-initial-download-url.com', // Replace with initial download URL
    };
    remoteConfig.setDefaults(defaultConfig);

    // Fetch and activate Firebase Remote Config
    Future<void> fetchAndActivateRemoteConfig() async {
      await remoteConfig.fetchAndActivate();
    }

    Future.delayed(const Duration(seconds: 3), () async {
      await fetchAndActivateRemoteConfig();
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        bool updateRequired = await checkForUpdate(context, remoteConfig);

        if (!updateRequired) {
          if (user != null) {
            await checkUserDetails(user.uid, context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GoogleAuthScreen(),
              ),
            );
          }
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
              width: double.infinity,
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
        await databaseReference.child('User_Information').child(userId).get();

    if (dataSnapshot.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const NextScreen(), // Replace with your next screen
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const GoogleAuthScreen(), // Replace with your fill details screen
        ),
      );
    }
  }

  Future<bool> checkForUpdate(
      BuildContext context, FirebaseRemoteConfig remoteConfig) async {
    try {
      final requiredVersion = remoteConfig.getString('required_version');
      print('Required version from Remote Config: $requiredVersion');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print('Current app version: $currentVersion');

      if (requiredVersion != currentVersion) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
                'A new version of the app is available. Please update to continue.'),
            actions: [
              TextButton(
                onPressed: () async {
                  final url = Uri.parse(remoteConfig.getString('update_url'));
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    print('Could not launch $url');
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );

        return true;
      }
    } catch (e) {
      print('Error checking for update: $e');
    }

    return false;
  }
}
