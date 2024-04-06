// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print, unused_element, duplicate_ignore

import 'dart:async';
import 'dart:io';

import 'package:chat_bot/screens/Sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

import 'package:permission_handler/permission_handler.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  bool _isRecording = false;
  bool _isThinking = false;
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
    _audioPlayer = FlutterSoundPlayer();
  }

  // @override
  // void dispose() {
  //   _audioPlayer!.closeAudioSession();
  //   super.dispose();
  // }

  // ignore: unused_element
  Future<void> _requestMicrophonePermission() async {
    // Request microphone permission
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Microphone permission denied');
      // Handle permission denied scenario, for example, by showing a message to the user
    }
  }

  @override
  void dispose() {
    _audioRecorder!.stopRecorder();
    _audioRecorder!.closeRecorder(); // Close the recorder
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
    await _audioRecorder!.openRecorder(); // Open the recorder
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      // Start recording
      await _startRecording();
    } else {
      // Stop recording
      await _stopRecording();

      await _submitAudioToAPI();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Microphone permission not granted');
        // Handle permission denied scenario, for example, by showing a message to the user
        return;
      }

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String recordingPath = '$tempPath/recording.wav';

      // Check if the recorder is already recording, stop it first
      if (_audioRecorder!.isRecording) {
        await _stopRecording();
      }

      await _audioRecorder!.startRecorder(toFile: recordingPath);
      print('Recording started');
      setState(() {
        _isRecording = true;
        _isThinking = false;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Stop the recording
      await _audioRecorder!.stopRecorder();
      print('Recording stopped');
      setState(() {
        _isRecording = false; // Make sure to set _isRecording to false
        _isThinking = true;
      });
      // Call _submitAudioToAPI here after setting _isRecording to false
      await _submitAudioToAPI();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<bool> _submitAudioToAPI() async {
    try {
      // Construct the request body
      var requestBody = {
        'userId': _userId!,
        'language': 'english', // Replace with the actual language
      };

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://conceptcure.centralindia.cloudapp.azure.com/upload'),
      );

      // Add user ID and language to the request body
      request.fields.addAll(requestBody);

      // Add the audio file to the request as a file part
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          recordingPath!,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      // Print a message before sending the request
      print('Sending API request...');

      // Send the request
      var response = await request.send();

      // Print a message after sending the request
      print('API request sent');

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Request successful, set state to show "Speaking" gif
        setState(() {
          _isThinking = false;
        });
        print('API request successful');
        return true;
      } else {
        // Request failed
        print('API request failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // An error occurred
      print('Error sending API request: $e');
      return false;
    }
  }

  Future<void> _downloadAndPlayAudio(Stream<List<int>> audioStream) async {
    try {
      // Create a temporary directory to store the downloaded audio file
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String audioPath = '$tempPath/api_response.wav';

      // Create a file to store the downloaded audio
      File audioFile = File(audioPath);
      // Write the audio stream to the file
      await audioFile.writeAsBytes((await audioStream.toList()).cast<int>());

      // Play the downloaded audio file
      await _audioPlayer!.startPlayer(fromURI: audioPath);
    } catch (e) {
      print('Error downloading and playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isRecording
                    ? Column(
                        children: [
                          const SizedBox(height: 1),
                          SizedBox(
                            width:
                                double.infinity, // Occupy entire screen width
                            height:
                                500, // Adjust the height as per your preference
                            child: Image.asset(
                              'assets/image24.png',
                              fit: BoxFit
                                  .cover, // Ensure the image covers the entire container
                            ),
                          ),
                        ],
                      )
                    : _isThinking
                        ? Column(
                            children: [
                              const Text(
                                'Wait a moment!\nProcessing...',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double
                                    .infinity, // Occupy entire screen width
                                height:
                                    400, // Adjust the height as per your preference
                                child: Image.asset(
                                  'assets/Thinking.png',
                                  fit: BoxFit
                                      .cover, // Ensure the image covers the entire container
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: ElevatedButton(
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: _isRecording
                    ? Colors.red
                    : const Color.fromARGB(255, 7, 133, 236),
                padding: const EdgeInsets.all(15),
                elevation: _isRecording ? 8 : 0,
              ),
              child: const Icon(
                Icons.mic,
                size: 40,
                color: Colors.black,
              ),
            ),
          ),
        ],
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
    );
  }
}
