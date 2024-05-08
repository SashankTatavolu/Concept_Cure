import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_bot/screens/Sign_in.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  bool _isRecording = false;
  bool _isThinking = false;
  bool _isPlayingAudio = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? recordingPath;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    _getCurrentUser();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioRecorder?.stopRecorder();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _userName = user.displayName;
        _userEmail = user.email;
      });
    }
  }

  Future<void> _initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer ??= FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
  }

  // Future<void> _toggleRecording() async {
  //   if (!_isRecording) {
  //     await _startRecording();
  //   } else {
  //     await _stopRecording();
  //   }
  // }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      if (_isPlayingAudio) {
        await _stopAudioPlayback(); // Stop audio playback if it's ongoing
      }
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _stopAudioPlayback() async {
    try {
      await _audioPlayer!.stopPlayer(); // Stop audio playback
      setState(() {
        _isPlayingAudio = false;
      });
    } catch (e) {
      print('Error stopping audio playback: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Microphone permission not granted');
        return;
      }

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      recordingPath = '$tempPath/recording.wav';

      if (_audioRecorder!.isRecording) {
        await _stopRecording();
      }

      await _audioRecorder!.startRecorder(toFile: recordingPath);
      print('Recording started');
      setState(() {
        _isRecording = true;
        _isThinking = false;
        _isPlayingAudio = false; // Reset playing audio flag
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder!.stopRecorder();
      print('Recording stopped');
      setState(() {
        _isRecording = false;
        _isThinking = true;
      });
      await _submitAudioToAPI();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _submitAudioToAPI() async {
    try {
      var requestBody = {
        'userId': _userId!,
        'language': 'en',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://conceptcure.centralindia.cloudapp.azure.com:443/upload'),
      );

      request.fields.addAll(requestBody);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          recordingPath!,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      print('Sending API request...');
      var response = await request.send();
      print('API request sent');

      if (response.statusCode == 200) {
        setState(() {
          _isThinking = false;
          _isPlayingAudio = true;
        });
        print('API request successful');

        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        var audioUrl = jsonResponse['audio_file'];

        await _audioPlayer!.startPlayer(
          fromURI: audioUrl,
          whenFinished: () {
            setState(() {
              _isPlayingAudio = false;
            });
          },
        );
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending API request: $e');
    }
  }

  Widget _buildGif(String assetName) {
    return Image.asset(
      'assets/$assetName.gif',
      gaplessPlayback: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
      ),
      body: Center(
        child: _isRecording
            ? _buildGif('Listening')
            : _isThinking
                ? _buildGif('Thinking')
                : _isPlayingAudio
                    ? _buildGif('Speaking')
                    : const SizedBox(),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: _userId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(_auth.currentUser!.photoURL ?? ''),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _userName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _userEmail ?? 'Email not available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ),
            ListTile(
              title: const Text('New Conversation'),
              onTap: () {
                // Implement new conversation action
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
                // Implement profile action
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                right: 16, bottom: 80), // Adjust bottom padding if needed
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      // Handle upload icon pressed
                    },
                    backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
                    mini: true,
                    child: const Icon(Icons.upload),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      // Handle camera icon pressed
                    },
                    backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
                    mini: true,
                    child: const Icon(Icons.camera_alt),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      // Handle keyboard icon pressed
                    },
                    backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
                    mini: true,
                    child: const Icon(Icons.keyboard),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: _toggleRecording,
                backgroundColor: _isRecording
                    ? Colors.red
                    : const Color.fromRGBO(217, 223, 235, 1),
                child: const Icon(Icons.mic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:chat_bot/screens/Sign_in.dart';

// class NextScreen extends StatefulWidget {
//   const NextScreen({super.key});

//   @override
//   _NextScreenState createState() => _NextScreenState();
// }

// class _NextScreenState extends State<NextScreen> {
//   bool _isRecording = false;
//   bool _isThinking = false;
//   bool _isPlayingAudio = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   FlutterSoundRecorder? _audioRecorder;
//   FlutterSoundPlayer? _audioPlayer;
//   String? _userId;
//   String? _userName;
//   String? _userEmail;
//   String? recordingPath;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioRecorder();
//     _getCurrentUser();
//     _initAudioPlayer();
//   }

//   @override
//   void dispose() {
//     _audioRecorder?.stopRecorder();
//     _audioRecorder?.closeRecorder();
//     _audioPlayer?.closePlayer();
//     super.dispose();
//   }

//   Future<void> _getCurrentUser() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         _userId = user.uid;
//         _userName = user.displayName;
//         _userEmail = user.email;
//       });
//     }
//   }

//   Future<void> _initAudioRecorder() async {
//     _audioRecorder = FlutterSoundRecorder();
//     await _audioRecorder!.openRecorder();
//   }

//   Future<void> _initAudioPlayer() async {
//     _audioPlayer ??= FlutterSoundPlayer();
//     await _audioPlayer!.openPlayer();
//   }

//   Future<void> _toggleRecording() async {
//     if (!_isRecording) {
//       await _startRecording();
//     } else {
//       await _stopRecording();
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       PermissionStatus status = await Permission.microphone.request();
//       if (!status.isGranted) {
//         print('Microphone permission not granted');
//         return;
//       }

//       Directory tempDir = await getTemporaryDirectory();
//       String tempPath = tempDir.path;
//       recordingPath = '$tempPath/recording.wav';

//       if (_audioRecorder!.isRecording) {
//         await _stopRecording();
//       }

//       await _audioRecorder!.startRecorder(toFile: recordingPath);
//       print('Recording started');
//       setState(() {
//         _isRecording = true;
//         _isThinking = false;
//         _isPlayingAudio = false; // Reset playing audio flag
//       });
//     } catch (e) {
//       print('Error starting recording: $e');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       await _audioRecorder!.stopRecorder();
//       print('Recording stopped');
//       setState(() {
//         _isRecording = false;
//         _isThinking = true;
//       });
//       await _submitAudioToAPI();
//     } catch (e) {
//       print('Error stopping recording: $e');
//     }
//   }

//   Future<void> _submitAudioToAPI() async {
//     try {
//       var requestBody = {
//         'userId': _userId!,
//         'language': 'en',
//       };

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'http://conceptcure.centralindia.cloudapp.azure.com:443/upload'),
//       );

//       request.fields.addAll(requestBody);

//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'file',
//           recordingPath!,
//           contentType: MediaType('audio', 'wav'),
//         ),
//       );

//       print('Sending API request...');
//       var response = await request.send();
//       print('API request sent');

//       if (response.statusCode == 200) {
//         setState(() {
//           _isThinking = false;
//           _isPlayingAudio = true;
//         });
//         print('API request successful');

//         var responseBody = await response.stream.bytesToString();
//         var jsonResponse = json.decode(responseBody);
//         var audioUrl = jsonResponse['audio_file'];

//         await _audioPlayer!.startPlayer(
//           fromURI: audioUrl,
//           whenFinished: () {
//             setState(() {
//               _isPlayingAudio = false;
//             });
//           },
//         );
//       } else {
//         print('API request failed with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending API request: $e');
//     }
//   }

//   Widget _buildGif(String assetName) {
//     return Image.asset(
//       'assets/$assetName.gif',
//       gaplessPlayback: true,
//     );
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//       ),
//       body: Center(
//         child: _isRecording
//             ? _buildGif('Listening')
//             : _isThinking
//                 ? _buildGif('Thinking')
//                 : _isPlayingAudio
//                     ? _buildGif('Speaking')
//                     : const SizedBox(),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: _userId != null
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundImage:
//                               NetworkImage(_auth.currentUser!.photoURL ?? ''),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           _userName ?? '',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           _userEmail ?? 'Email not available',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     )
//                   : Container(),
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
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignInScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _toggleRecording,
//         backgroundColor:
//             _isRecording ? Colors.red : const Color.fromRGBO(217, 223, 235, 1),
//         child: const Icon(Icons.mic),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             FloatingActionButton(
//               onPressed: () {
//                 // Handle upload icon pressed
//               },
//               backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//               mini: true,
//               child: const Icon(Icons.upload),
//             ),
//             const SizedBox(height: 16),
//             FloatingActionButton(
//               onPressed: () {
//                 // Handle camera icon pressed
//               },
//               backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//               mini: true,
//               child: const Icon(Icons.camera_alt),
//             ),
//             const SizedBox(height: 16),
//             FloatingActionButton(
//               onPressed: () {
//                 // Handle keyboard icon pressed
//               },
//               backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//               mini: true,
//               child: const Icon(Icons.keyboard),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
