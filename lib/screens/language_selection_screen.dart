// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:chat_bot/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  List<String> _languages = [];
  final DatabaseReference _languageDatabase =
      FirebaseDatabase.instance.ref('Sample_Data/Languages');
  final DatabaseReference _userDatabase =
      FirebaseDatabase.instance.ref('User_Information');

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  void _fetchLanguages() async {
    try {
      DataSnapshot snapshot = await _languageDatabase.get();
      if (snapshot.exists) {
        Map<String, dynamic> languagesMap =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _languages = languagesMap.values.map((e) => e.toString()).toList();
        });
      } else {
        print("No data available.");
      }
    } catch (error) {
      print('Error fetching languages: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CustomDropdown(
                label: 'Select Language',
                options: _languages,
                selectedOption: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
              const SizedBox(height: 30, width: 246),
              ElevatedButton(
                onPressed: () {
                  if (_selectedLanguage != null) {
                    _saveSelectedLanguage(_selectedLanguage!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content:
                            const Text('Please select a language to proceed.'),
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Increase vertical padding
                  minimumSize: const Size(220, 50), // Set button minimum size
                  backgroundColor: Colors.blue, // Set background color to blue
                  shape: RoundedRectangleBorder(
                    // Set border radius
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSelectedLanguage(String language) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDatabase.child(user.uid).set({
        'language': language,
      }).then((_) {
        // Language saved successfully
        print('Language saved: $language');
      }).catchError((error) {
        // Handle error saving language
        print('Error saving language: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save language. Please try again.'),
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
}

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?>? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    this.selectedOption,
    this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.label),
                  Icon(_isExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4.0),
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
              children: widget.options.map((option) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.onChanged?.call(option);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: option,
                              groupValue: widget.selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  widget.onChanged?.call(value);
                                });
                              },
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.black,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: widget.selectedOption == option
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 0, thickness: 1),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
