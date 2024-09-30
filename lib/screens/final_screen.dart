// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:chat_bot/screens/chat_screen.dart';
import 'package:chat_bot/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_bot/screens/Confusionscreen.dart';
import 'package:chat_bot/screens/Sign_in.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> _selectedInterests = [];
  List<String> _interestsOptions = [];
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('User_Information');

  late User? _user;
  late String _firstName = '';
  late String _lastName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
    _fetchInterestsOptions();
  }

  Future<void> _fetchUserInformation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        List<String> nameParts = user.displayName!.split(' ');
        _firstName = nameParts.first;
        _lastName = nameParts.length > 1 ? nameParts.last : '';
      });
    }
  }

  Future<void> _fetchInterestsOptions() async {
    DatabaseReference interestsRef =
        FirebaseDatabase.instance.ref('Sample_Data/Interests');
    DatabaseEvent event = await interestsRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> interestsMap =
          event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _interestsOptions = interestsMap.values.cast<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
            backgroundColor: const Color.fromARGB(255, 217, 223, 235),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            )),
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
                    '$_lastName, $_firstName',
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
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'You did it!\n',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'You\'re on board',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown(
                      label: 'Select Interests',
                      options: _interestsOptions,
                      selectedOptions: _selectedInterests,
                      onChanged: (List<String> values) {
                        setState(() {
                          _selectedInterests = values;
                        });
                      },
                    ),
                    const SizedBox(height: 20, width: 246),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedInterests.length >= 2) {
                          _saveSelectedInterests(_selectedInterests);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConfusionScreen(),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'Please select at least 2 Interests to proceed.'),
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
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        minimumSize: const Size(220, 50),
                        backgroundColor:
                            const Color.fromARGB(255, 58, 151, 228),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSelectedInterests(List<String> interests) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _database.child(user.uid).update({'interests': interests});
    }
  }
}

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>>? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isExpanded = false;
  final TextEditingController _interestController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    _filteredOptions = widget.options.where((option) {
      return option
          .toLowerCase()
          .contains(_interestController.text.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            height: 120,
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
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: _filteredOptions.map((option) {
                  final bool isSelected =
                      widget.selectedOptions.contains(option);
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              widget.selectedOptions.remove(option);
                            } else {
                              widget.selectedOptions.add(option);
                            }
                          });
                          widget.onChanged?.call(widget.selectedOptions);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      widget.selectedOptions.add(option);
                                    } else {
                                      widget.selectedOptions.remove(option);
                                    }
                                  });
                                  widget.onChanged
                                      ?.call(widget.selectedOptions);
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
                                    color: isSelected ? Colors.grey : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0,
                        thickness: 1,
                      ),
                    ],
                  );
                }).toList(),
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
            child: TextField(
              controller: _interestController,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                if (value.isNotEmpty && !_filteredOptions.contains(value)) {
                  setState(() {
                    widget.options.add(value);
                    widget.selectedOptions.add(value);
                    _interestController.clear();
                  });
                  widget.onChanged?.call(widget.selectedOptions);
                }
              },
              decoration: const InputDecoration(
                hintText: 'Type your interests',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ),
      ],
    );
  }
}
