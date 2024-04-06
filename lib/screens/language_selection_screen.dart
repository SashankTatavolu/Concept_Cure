// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:chat_bot/screens/google_auth_screen.dart';

// class LanguageSelectionScreen extends StatefulWidget {
//   const LanguageSelectionScreen({super.key});

//   @override
//   _LanguageSelectionScreenState createState() =>
//       _LanguageSelectionScreenState();
// }

// class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
//   List<String> _selectedLanguages = [];
//   final DatabaseReference _database =
//       FirebaseDatabase.instance.ref('User_Information');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
//       ),
//       body: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.8,
//           height: MediaQuery.of(context).size.height * 0.8,
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               CustomDropdown(
//                 label: 'Select Language',
//                 options: const [
//                   'English',
//                   'Bengali',
//                   'Hindi',
//                   'Punjabi',
//                   'Marathi',
//                   'Telugu',
//                   'Malayalam'
//                 ],
//                 selectedOptions: _selectedLanguages,
//                 onChanged: (List<String> values) {
//                   setState(() {
//                     _selectedLanguages = values;
//                   });
//                 },
//               ),
//               const SizedBox(height: 30, width: 246),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_selectedLanguages.length >= 2) {
//                     _saveSelectedLanguages(_selectedLanguages);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const GoogleAuthScreen()),
//                     );
//                   } else {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Error'),
//                         content: const Text(
//                             'Please select at least 2 languages to proceed.'),
//                         actions: [
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text('OK'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 16.0), // Increase vertical padding
//                   minimumSize: const Size(220, 50), // Set button minimum size
//                   backgroundColor: Colors.blue, // Set background color to blue
//                   shape: RoundedRectangleBorder(
//                     // Set border radius
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 child: const Text(
//                   'Next',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _saveSelectedLanguages(List<String> languages) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _database.child(user.uid).set({
//         'languages': languages,
//       }).then((_) {
//         // Languages saved successfully
//         print('Languages saved: $languages');
//       }).catchError((error) {
//         // Handle error saving languages
//         print('Error saving languages: $error');
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Error'),
//             content: const Text('Failed to save languages. Please try again.'),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//     }
//   }
// }

// class CustomDropdown extends StatefulWidget {
//   final String label;
//   final List<String> options;
//   final List<String> selectedOptions;
//   final ValueChanged<List<String>>? onChanged;

//   const CustomDropdown({
//     super.key,
//     required this.label,
//     required this.options,
//     required this.selectedOptions,
//     this.onChanged,
//   });

//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }

// class _CustomDropdownState extends State<CustomDropdown> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.0),
//             border: Border.all(color: Colors.black),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//             color: Colors.white,
//           ),
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isExpanded = !_isExpanded;
//               });
//             },
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(15.0),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.transparent),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(widget.label),
//                   Icon(_isExpanded
//                       ? Icons.arrow_drop_up
//                       : Icons.arrow_drop_down),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (_isExpanded)
//           Container(
//             margin: const EdgeInsets.only(top: 4.0),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               border: Border.all(color: Colors.black),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               color: Colors.white,
//             ),
//             child: Column(
//               children: widget.options.map((option) {
//                 final bool isSelected = widget.selectedOptions.contains(option);
//                 return Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           if (isSelected) {
//                             widget.selectedOptions.remove(option);
//                           } else {
//                             widget.selectedOptions.add(option);
//                           }
//                         });
//                         widget.onChanged?.call(widget.selectedOptions);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           children: [
//                             Checkbox(
//                               value: isSelected,
//                               onChanged: (value) {
//                                 setState(() {
//                                   if (value != null && value) {
//                                     widget.selectedOptions.add(option);
//                                   } else {
//                                     widget.selectedOptions.remove(option);
//                                   }
//                                 });
//                                 widget.onChanged?.call(widget.selectedOptions);
//                               },
//                             ),
//                             Container(
//                               width: 1,
//                               height: 24,
//                               color: Colors.black,
//                               margin:
//                                   const EdgeInsets.symmetric(horizontal: 8.0),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 option,
//                                 style: TextStyle(
//                                   color: isSelected ? Colors.grey : null,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Divider(height: 0, thickness: 1),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//       ],
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_bot/screens/google_auth_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<String> _selectedLanguages = [];
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Sample_Data').child('Languages');

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  void _fetchLanguages() {
    _database.once().then((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      List<String> languages = [];

      values.forEach((key, value) {
        if (key.startsWith('I_')) {
          // Assuming language keys start with 'I_'
          languages.add(value);
        }
      });

      setState(() {
        _selectedLanguages = languages;
      });

      print('Languages retrieved from the database: $languages');
    }).catchError((error) {
      print('Error fetching languages: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 223, 235, 1),
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
                options: _selectedLanguages,
                selectedOptions: _selectedLanguages,
                onChanged: (List<String> values) {
                  setState(() {
                    _selectedLanguages = values;
                  });
                },
              ),
              const SizedBox(height: 30, width: 246),
              ElevatedButton(
                onPressed: () {
                  if (_selectedLanguages.length >= 2) {
                    _saveSelectedLanguages(_selectedLanguages);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GoogleAuthScreen()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please select at least 2 languages to proceed.'),
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

  void _saveSelectedLanguages(List<String> languages) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Assuming 'User_Information' is the reference for user information in your database
      FirebaseDatabase.instance
          .ref()
          .child('User_Information')
          .child(user.uid)
          .child('languages')
          .set(languages)
          .then((_) {
        // Languages saved successfully
        print('Languages saved: $languages');
      }).catchError((error) {
        // Handle error saving languages
        print('Error saving languages: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save languages. Please try again.'),
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
  final List<String> selectedOptions;
  final ValueChanged<List<String>>? onChanged;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    this.onChanged,
  }) : super(key: key);

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
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
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
                final bool isSelected = widget.selectedOptions.contains(option);
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                widget.onChanged?.call(widget.selectedOptions);
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
