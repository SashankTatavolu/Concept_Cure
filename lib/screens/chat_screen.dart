import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/screens/profile_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_bot/screens/Sign_in.dart';
// import 'package:flutter/services.dart' show ByteData, rootBundle;

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isThinking = false;
  bool _isPlayingAudio = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _userEmail;
  String? recordingPath;
  Timer? _responseTimer;
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('User_Information');
  static bool _greetingPlayed = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    _getCurrentUser();
    _initAudioPlayer();
    _initAnimationController();
  }

  void _initAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _audioRecorder?.stopRecorder();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    _stopAudioPlayback();
    _responseTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      _userEmail = user.email;
      _database.child(_userId!).once().then((event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          var data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _firstName = data['first_name'];
            _lastName = data['last_name'];
          });
        }
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

    if (!_greetingPlayed) {
      ByteData audioData = await rootBundle.load('assets/Greeting.wav');
      List<int> audioBytes = audioData.buffer.asUint8List();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String audioFilePath = '$tempPath/your_audio_file.wav';
      await File(audioFilePath).writeAsBytes(audioBytes);

      await _audioPlayer!.startPlayer(
        fromURI: audioFilePath,
        whenFinished: () {
          setState(() {
            _isPlayingAudio = false;
          });
        },
      );

      setState(() {
        _isPlayingAudio = true;
        _greetingPlayed = true; // Set the flag after playing the greeting
      });
    }
  }

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
      _animationController.forward();
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
      _animationController.reverse();
      setState(() {
        _isRecording = false;
        _isThinking = true;
      });
      _startResponseTimer(); // Start the response timer
      await _submitAudioToAPI();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _startResponseTimer() {
    _responseTimer?.cancel();
    _responseTimer = Timer(const Duration(seconds: 30), () {
      if (_isThinking) {
        _showTryAgainDialog();
      }
    });
  }

  Future<void> _showTryAgainDialog() async {
    if (mounted) {
      setState(() {
        _isThinking = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Response Timeout'),
          content: const Text(
              'The response is taking longer than expected. Please try recording again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _submitAudioToAPI() async {
    String? baseUrl = await _fetchBaseUrl();

    try {
      // Fetch user's language from Firebase Realtime Database
      String? userLanguage = await _fetchUserLanguageFromFirebase();

      // Map language to short code
      String languageCode;
      if (userLanguage == 'Telugu') {
        languageCode = 'te';
      } else if (userLanguage == 'Hindi') {
        languageCode = 'hi';
      } else {
        languageCode = 'en'; // Default to English for other languages
      }

      var requestBody = {
        'userId': _userId!,
        'language': languageCode, // Use the dynamically fetched language code
      };

      print(requestBody);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
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

        _responseTimer?.cancel(); // Cancel the response timer
        setState(() {
          _isThinking = false;
          _isPlayingAudio = true;
        });
        print('API request successful');
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending API request: $e');
    }
  }

  Future<String?> _fetchUserLanguageFromFirebase() async {
    String userId = _userId!; // Assuming you already have the user ID available
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('User_Information/$userId');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(snapshot.value as Map);
      return userData['language'];
    } else {
      print('User data not found in Firebase');
      return null;
    }
  }

  Future<String?> _fetchBaseUrl() async {
    try {
      final DatabaseReference database =
          FirebaseDatabase.instance.ref('baseUrl');
      DataSnapshot snapshot = await database.get();
      return snapshot.value.toString();
    } catch (e) {
      print('Error fetching base URL: $e');
      return null;
    }
  }

  Widget _buildGif(String type, String status) {
    String imagePath;
    switch (type) {
      case 'Listening':
        imagePath = 'assets/Listening.gif';
        break;
      case 'Thinking':
        imagePath = 'assets/Thinking.gif';
        break;
      case 'Speaking':
        imagePath = 'assets/Speaking.gif';
        break;
      default:
        imagePath = 'assets/Listening.gif';
    }
    return Center(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: 550,
        width: 400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Stack(
            children: [
              _buildGif('Listening', ''),
              if (_isThinking) _buildGif('Thinking', ''),
              if (_isPlayingAudio) _buildGif('Speaking', ''),
            ],
          ),
        ),
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
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
                            '$_firstName $_lastName',
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
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NextScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onLongPress: _toggleRecording,
            onLongPressUp: _stopRecording,
            child: ScaleTransition(
              scale: _isRecording
                  ? Tween<double>(begin: 1.0, end: 1.2)
                      .animate(_animationController)
                  : Tween<double>(begin: 1.0, end: 1.0)
                      .animate(_animationController),
              child: FloatingActionButton(
                backgroundColor: _isRecording
                    ? Colors.red
                    : const Color.fromRGBO(217, 223, 235, 1),
                onPressed: () {},
                child: const Icon(Icons.mic),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
