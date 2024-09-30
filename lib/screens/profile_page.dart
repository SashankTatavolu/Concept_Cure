// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  String _firstName = '';
  String _lastName = '';
  String _gender = '';
  String _class = '';
  String _schoolName = '';
  String _secretCode = '';
  String _mobileNumber = '';
  List<String> _interests = [];
  String _language = '';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _secretCodeController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  Future<void> _fetchUserInformation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _user = user;
        });

        DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('User_Information')
            .child(user.uid);

        DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          Map userData = snapshot.value as Map;
          setState(() {
            _firstName = userData['first_name'] ?? '';
            _lastName = userData['last_name'] ?? '';
            _gender = userData['gender'] ?? '';
            _class = userData['class'] ?? '';
            _schoolName = userData['school_name'] ?? '';
            _secretCode = userData['secret_code'] ?? '';
            _mobileNumber = userData['mobile_number'] ?? '';
            _interests =
                (userData['interests'] as List<dynamic>).cast<String>();
            _language = userData['language'] ?? '';

            _firstNameController.text = _firstName;
            _lastNameController.text = _lastName;
            _genderController.text = _gender;
            _classController.text = _class;
            _schoolNameController.text = _schoolName;
            _secretCodeController.text = _secretCode;
            _mobileNumberController.text = _mobileNumber;
            _interestsController.text = _interests.join(', ');
            _languageController.text = _language;

            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user information: $error");
    }
  }

  Future<void> _saveUserInformation() async {
    if (_user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('User_Information')
          .child(_user!.uid);
      await userRef.update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _genderController.text,
        'class': _classController.text,
        'school_name': _schoolNameController.text,
        'secret_code': _secretCodeController.text,
        'mobile_number': _mobileNumberController.text,
        'interests':
            _interestsController.text.split(',').map((e) => e.trim()).toList(),
        'language': _languageController.text,
      });

      setState(() {
        _firstName = _firstNameController.text;
        _lastName = _lastNameController.text;
        _gender = _genderController.text;
        _class = _classController.text;
        _schoolName = _schoolNameController.text;
        _secretCode = _secretCodeController.text;
        _mobileNumber = _mobileNumberController.text;
        _interests =
            _interestsController.text.split(',').map((e) => e.trim()).toList();
        _language = _languageController.text;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(35.0),
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        _buildProfileItem(
                            'First Name', _firstName, _firstNameController),
                        _buildProfileItem(
                            'Last Name', _lastName, _lastNameController),
                        _buildProfileItem('Gender', _gender, _genderController),
                        _buildProfileItem('Class', _class, _classController),
                        _buildProfileItem(
                            'School Name', _schoolName, _schoolNameController),
                        _buildProfileItem(
                            'Secret Code', _secretCode, _secretCodeController),
                        _buildProfileItem('Mobile Number', _mobileNumber,
                            _mobileNumberController),
                        _buildProfileItem('Interests', _interests.join(', '),
                            _interestsController),
                        _buildProfileItem(
                            'Languages', _language, _languageController),
                        const SizedBox(height: 20),
                        _isEditing
                            ? ElevatedButton(
                                onPressed: _saveUserInformation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
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
                    '$_firstName $_lastName',
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
            // ListTile(
            //   title: const Text('History'),
            //   onTap: () {
            //     // Implement history action
            //   },
            // ),
            // ListTile(
            //   title: const Text('Calendar'),
            //   onTap: () {
            //     // Implement calendar action
            //   },
            // ),
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

  Widget _buildProfileItem(
      String label, String value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 0.5),
          Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: value,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              if (_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                ),
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(top: 2),
          ),
        ],
      ),
    );
  }
}
