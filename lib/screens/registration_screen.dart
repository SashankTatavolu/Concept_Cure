// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_bot/screens/final_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _selectedClass;
  String? _selectedBoard;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _secretCodeController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('User_Information');
  List<String> _boardOptions = [];
  List<String> _genderOptions = [];
  List<String> _classOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  void _fetchOptions() {
    final DatabaseReference database =
        FirebaseDatabase.instance.ref('Sample_Data');

    database.child('Board').once().then((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        List<String> boards =
            data.values.map<String>((value) => value.toString()).toList();

        setState(() {
          _boardOptions = boards..sort(); // Sorting alphabetically
        });

        print('Board options retrieved: $_boardOptions');
      } else {
        print('Error: Board data is not in the correct format');
      }
    }).catchError((error) {
      print('Error fetching gender options: $error');
    });

    database.child('Gender').once().then((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        List<String> genders =
            data.values.map<String>((value) => value.toString()).toList();

        setState(() {
          _genderOptions = genders..sort(); // Sorting alphabetically
        });

        print('Gender options retrieved: $_genderOptions');
      } else {
        print('Error: Gender data is not in the correct format');
      }
    }).catchError((error) {
      print('Error fetching gender options: $error');
    });

    database.child('Class').once().then((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        List<String> classes = data.values
            .map<String>((value) => value.toString()) // Convert to string
            .toList();

        classes.sort(); // Sorting in ascending order

        setState(() {
          _classOptions = classes;
        });

        print('Class options retrieved: $_classOptions');
      } else {
        print('Error: Class data is not in the correct format');
      }
    }).catchError((error) {
      print('Error fetching class options: $error');
    });
  }

  Future<String?> _fetchBaseUrl() async {
    try {
      final DatabaseReference database =
          FirebaseDatabase.instance.ref('baseUrl');
      DataSnapshot snapshot = await database.get();

      if (snapshot.exists) {
        String? baseUrl = snapshot.value as String?;
        print('Base URL fetched: $baseUrl');
        return baseUrl;
      } else {
        print('Base URL not found in the database.');
        return null;
      }
    } catch (error) {
      print('Error fetching Base URL: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(35.0),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 1),
                    const Text(
                      'Initial\nRegistration',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField('First Name', _firstNameController),
                    _buildTextField('Last Name', _lastNameController),
                    _buildDropdown(
                      'Gender',
                      _genderOptions,
                      _selectedGender,
                      (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    _buildDropdown(
                      'Board',
                      _boardOptions,
                      _selectedBoard,
                      (value) {
                        setState(() {
                          _selectedBoard = value;
                        });
                      },
                    ),
                    _buildDropdown(
                      'Class',
                      _classOptions,
                      _selectedClass,
                      (value) {
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                    ),
                    _buildTextField('School Name', _schoolNameController),
                    _buildTextField('Secret Code', _secretCodeController,
                        isOptional: true),
                    _buildTextField('Mobile Number', _mobileNumberController,
                        numericOnly: true),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveRegistrationDetails();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InterestsScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Save and Proceed',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool numericOnly = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            validator: (value) {
              if (value!.isEmpty && !isOptional) {
                return 'Please enter your $label';
              }
              return null;
            },
            keyboardType:
                numericOnly ? TextInputType.number : TextInputType.text,
            inputFormatters: numericOnly
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                : null,
            decoration: InputDecoration(
              labelText: isOptional ? '$label (Optional)' : label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black)),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select $label'),
                value: selectedValue,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveRegistrationDetails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _database.child(user.uid).update({
        'board': _selectedBoard,
        'class': _selectedClass,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'school_name': _schoolNameController.text,
        'secret_code': _secretCodeController.text,
        'mobile_number': _mobileNumberController.text,
        'gender': _selectedGender,
      }).then((_) {
        // Registration details saved successfully
        print('Registration details saved');

        // Make API call to register user on your server
        _registerUserOnServer(user.uid);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterestsScreen(),
          ),
        );
      }).catchError((error) {
        // Handle error saving registration details
        print('Error saving registration details: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to save registration details. Please try again.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _registerUserOnServer(String userId) async {
    String? baseUrl = await _fetchBaseUrl();

    if (baseUrl == null) {
      print('Base URL not found. Cannot proceed with registration.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        print('User registered on server successfully');
      } else {
        print(
            'Failed to register user on server. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error registering user on server: $error');
    }
  }
}
