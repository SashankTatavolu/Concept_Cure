// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/main.dart';
import 'package:chat_bot/screens/profile_page.dart';
import 'package:chat_bot/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('User_Information');
  static bool _greetingPlayed = false;
  DateTime? _recordingStartTime;
  DateTime? _recordingEndTime;
  DateTime? _apiResponseTime;
  String? _currentSessionId;

  late AnimationController _animationController;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    _getCurrentUser();
    _initAudioPlayer();
    _initAnimationController();
    _configureFirebaseMessaging();
    _configureFlutterLocalNotifications();
  }

  void _initAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _configureFirebaseMessaging() async {
    try {
      await Firebase.initializeApp();

      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');

        String? token = await _firebaseMessaging.getToken();
        print("FCM Token: $token");

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Foreground message received: ${message.messageId}');
          _showNotification(message);
        });

        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('User opened notification');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ),
          );
        });
      } else {
        print('User declined or did not accept permission');
      }
    } catch (e) {
      print('Error in configuring Firebase Messaging: $e');
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    try {
      await Firebase.initializeApp(); // Ensure Firebase is initialized
      print('Handling a background message: ${message.messageId}');
    } catch (e) {
      print('Error in background message handler: $e');
    }
  }

  void _configureFlutterLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tapped logic here
        print('Notification tapped with payload: ${response.payload}');
      },
    );
  }

  void _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id', // Unique channel ID
        'your_channel_name', // Channel name
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: 'Notification Payload',
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder?.stopRecorder();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    _stopAudioPlayback();
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

    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('Microphone permission not granted');
    }
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer ??= FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();

    if (!_greetingPlayed) {
      // Fetch user's language from Firebase Realtime Database
      String? userLanguage = await _fetchUserLanguageFromFirebase();

      // Decide which greeting file to play based on the user's language
      String greetingFile;
      if (userLanguage == 'Telugu') {
        greetingFile = 'assets/teluguGreeting.wav';
      } else if (userLanguage == 'Hindi') {
        greetingFile = 'assets/hindiGreeting.wav';
      } else {
        greetingFile = 'assets/englishGreeting.wav'; // Default to English
      }

      // Load the audio data from the selected greeting file
      ByteData audioData = await rootBundle.load(greetingFile);
      List<int> audioBytes = audioData.buffer.asUint8List();

      // Save the file temporarily in the device's storage
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String audioFilePath = '$tempPath/greeting.wav';

      // Write the audio bytes to a file
      await File(audioFilePath).writeAsBytes(audioBytes);

      // Start playing the selected greeting file
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
      // Only start recording when the button is held down, not automatically
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Microphone permission not granted');
        return;
      }

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
      updateLastOpenedDate();
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

      _recordingStartTime = DateTime.now(); // Capture start time
      String sessionId = _recordingStartTime!.millisecondsSinceEpoch
          .toString(); // Unique session ID

      await _audioRecorder!.startRecorder(toFile: recordingPath);

      // **Save timestamp to Firebase**
      if (_userId != null) {
        DatabaseReference sessionRef = FirebaseDatabase.instance
            .ref('User_Knowledge_Base/$_userId/Recordings/$sessionId');
        await sessionRef.set({
          'recording_start': _recordingStartTime!.toIso8601String(),
        });
      }

      print('Recording started at $_recordingStartTime');
      _currentSessionId = sessionId; // Save session ID for later use

      _animationController.forward();

      setState(() {
        _isRecording = true;
        _isThinking = false;
        _isPlayingAudio = false;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder!.stopRecorder();
      _recordingEndTime = DateTime.now(); // Capture stop time

      // **Save timestamp to Firebase**
      if (_userId != null && _currentSessionId != null) {
        DatabaseReference sessionRef = FirebaseDatabase.instance
            .ref('User_Knowledge_Base/$_userId/Recordings/$_currentSessionId');
        await sessionRef.update({
          'recording_end': _recordingEndTime!.toIso8601String(),
        });
      }

      print('Recording stopped at $_recordingEndTime');

      Duration recordingDuration =
          _recordingEndTime!.difference(_recordingStartTime!);
      print('Total recording duration: ${recordingDuration.inMilliseconds} ms');

      _animationController.reverse();

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
    String? baseUrl = await _fetchBaseUrl();

    try {
      String? userLanguage = await _fetchUserLanguageFromFirebase();
      String languageCode = (userLanguage == 'Telugu')
          ? 'te'
          : (userLanguage == 'Hindi' || userLanguage == "Hindi+English")
              ? 'hi'
              : 'en';

      var requestBody = {
        'userId': _userId!,
        'language': languageCode,
      };

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

      DateTime apiRequestTime = DateTime.now(); // Capture API request time
      print('API request sent at $apiRequestTime');

      // **Save timestamp to Firebase**
      if (_userId != null && _currentSessionId != null) {
        DatabaseReference sessionRef = FirebaseDatabase.instance
            .ref('User_Knowledge_Base/$_userId/Recordings/$_currentSessionId');
        await sessionRef.update({
          'api_request': apiRequestTime.toIso8601String(),
        });
      }

      var response = await request.send();
      _apiResponseTime = DateTime.now(); // Capture response time

      // **Save timestamp to Firebase**
      if (_userId != null && _currentSessionId != null) {
        DatabaseReference sessionRef = FirebaseDatabase.instance
            .ref('User_Knowledge_Base/$_userId/Recordings/$_currentSessionId');
        await sessionRef.update({
          'api_response': _apiResponseTime!.toIso8601String(),
        });
      }

      Duration apiProcessingTime = _apiResponseTime!.difference(apiRequestTime);
      print('API response received at $_apiResponseTime');
      print('API processing time: ${apiProcessingTime.inMilliseconds} ms');

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        var audioUrl = jsonResponse['audio_file'];

        DateTime playbackStartTime =
            DateTime.now(); // Capture playback start time
        print('Starting playback at $playbackStartTime');

        await _audioPlayer!.startPlayer(
          fromURI: audioUrl,
          whenFinished: () {
            DateTime playbackEndTime =
                DateTime.now(); // Capture playback end time
            print('Playback finished at $playbackEndTime');

            Duration totalProcessingTime =
                playbackEndTime.difference(_recordingStartTime!);
            print(
                'Total time from recording start to output playback: ${totalProcessingTime.inMilliseconds} ms');

            setState(() {
              _isPlayingAudio = false;
            });
          },
        );

        setState(() {
          _isPlayingAudio = true;
        });
      } else {
        print('Error: API response failed');
      }
    } catch (e) {
      print('Error submitting audio to API: $e');
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
            onLongPress: () async {
              // Ensure microphone permission is granted before starting recording
              PermissionStatus status = await Permission.microphone.request();
              if (status.isGranted) {
                await _toggleRecording();
              } else {
                print('Microphone permission denied');
              }
            },
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
