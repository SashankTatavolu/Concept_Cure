// // ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, unused_import

// import 'package:chat_bot/screens/Sign_in.dart';
// import 'package:chat_bot/screens/google_auth_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_bot/screens/chat_screen.dart';

// class ConfusionScreen extends StatefulWidget {
//   const ConfusionScreen({Key? key});

//   @override
//   _ConfusionScreenState createState() => _ConfusionScreenState();
// }

// class _ConfusionScreenState extends State<ConfusionScreen> {
//   late User? _user;
//   late String _firstName = '';
//   late String _lastName = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserInformation();
//   }

//   Future<void> _fetchUserInformation() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         _user = user;
//         // Extracting first name and last name from user's display name
//         List<String> nameParts = user.displayName!.split(' ');
//         _firstName = nameParts.first;
//         _lastName = nameParts.length > 1 ? nameParts.last : '';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//     return Scaffold(
//       key: _scaffoldKey, // Assigning the key to the Scaffold
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//         automaticallyImplyLeading:
//             false, // Disable automatically added leading icon
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(40.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 20),
//             const ConfusionItem(
//               text: 'Let\'s',
//               imagePath: 'assets/capsule.png',
//             ),
//             const ConfusionItem(
//               text: 'Start',
//               imagePath: 'assets/capsule2.png',
//             ),
//             const ConfusionItem(
//               text: 'with',
//               imagePath: 'assets/capsule3.png',
//             ),
//             const ConfusionItem(
//               text: 'Yours',
//               imagePath: 'assets/capsule4.png',
//             ),
//             const ConfusionItem(
//               text: 'Today\'s',
//               imagePath: 'assets/capsule5.png',
//             ),
//             const ConfusionItem(
//               text: 'Confusion',
//               imagePath: 'assets/capsule6.png',
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const NextScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 minimumSize: const Size(double.infinity, 50),
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               child: const Center(
//                 child: Text(
//                   'Proceed',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage: NetworkImage(_user?.photoURL ?? ''),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     '$_firstName $_lastName ',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                     ),
//                   ),
//                   Text(
//                     _user?.email ?? 'Email not available',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               title: const Text('New Conversation'),
//               onTap: () {
//                 // Implement new conversation action
//               },
//             ),
//             ListTile(
//               title: const Text('History'),
//               onTap: () {
//                 // Implement history action
//               },
//             ),
//             ListTile(
//               title: const Text('Calendar'),
//               onTap: () {
//                 // Implement calendar action
//               },
//             ),
//             ListTile(
//               title: const Text('Profile'),
//               onTap: () {
//                 // Implement profile action
//               },
//             ),
//             ListTile(
//               title: const Text('Logout'),
//               onTap: () async {
//                 await FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(
//                   // ignore: use_build_context_synchronously
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignInScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(
//             top: 80.0), // Adding padding to adjust the position of the icon
//         child: FloatingActionButton(
//           onPressed: () {
//             _scaffoldKey.currentState!.openDrawer();
//           },
//           backgroundColor: const Color.fromARGB(255, 217, 223, 235),
//           child: const Icon(Icons.menu),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
//     );
//   }
// }

// class ConfusionItem extends StatelessWidget {
//   final String text;
//   final String imagePath;

//   const ConfusionItem({
//     super.key,
//     required this.text,
//     required this.imagePath,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Image.asset(
//             imagePath,
//             height: 70,
//             width: 50,
//           ),
//         ),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 38,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api

import 'package:chat_bot/screens/Sign_in.dart';
import 'package:chat_bot/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_bot/screens/chat_screen.dart';

class ConfusionScreen extends StatefulWidget {
  const ConfusionScreen({super.key});

  @override
  _ConfusionScreenState createState() => _ConfusionScreenState();
}

class _ConfusionScreenState extends State<ConfusionScreen> {
  late User? _user;
  late String _firstName = '';
  late String _lastName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  Future<void> _fetchUserInformation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        // Extracting first name and last name from user's display name
        List<String> nameParts = user.displayName!.split(' ');
        _firstName = nameParts.first;
        _lastName = nameParts.length > 1 ? nameParts.last : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

    return Scaffold(
      key: scaffoldKey, // Assigning the key to the Scaffold
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading:
            false, // Disable automatically added leading icon
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const ConfusionItem(
              text: 'Let\'s',
              imagePath: 'assets/capsule.png',
            ),
            const ConfusionItem(
              text: 'Start',
              imagePath: 'assets/capsule2.png',
            ),
            const ConfusionItem(
              text: 'with',
              imagePath: 'assets/capsule3.png',
            ),
            const ConfusionItem(
              text: 'Yours',
              imagePath: 'assets/capsule4.png',
            ),
            const ConfusionItem(
              text: 'Today\'s',
              imagePath: 'assets/capsule5.png',
            ),
            const ConfusionItem(
              text: 'Confusion',
              imagePath: 'assets/capsule6.png',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NextScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Center(
                child: Text(
                  'Proceed',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_user?.photoURL ?? ''),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_firstName $_lastName ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _user?.email ?? 'Email not available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const NextScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('History'),
              onTap: () {
                // Implement history action
              },
            ),
            ListTile(
              title: const Text('Calendar'),
              onTap: () {
                // Implement calendar action
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ConfusionItem extends StatelessWidget {
  final String text;
  final String imagePath;

  const ConfusionItem({
    super.key,
    required this.text,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            imagePath,
            height: 70,
            width: 50,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
