// import 'package:flutter/material.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SchoolScreen extends StatefulWidget {
//   @override
//   _SchoolScreenState createState() => _SchoolScreenState();
// }

// class _SchoolScreenState extends State<SchoolScreen> {
//   final List<String> schoolNames = [
//     'School A',
//     'School B',
//     'School C',
//     'School D',
//     'School E',
//     'School F',
//     'School G',
//     'School H',
//     'School I',
//     'School J',
//   ];

//   String? selectedSchool;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(50.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(
//                       'assets/cklogo.png',
//                     ),
//                     DropdownButtonFormField2<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Select School',
//                         labelStyle: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       hint: const Text('Choose School'),
//                       items: schoolNames
//                           .map((school) => DropdownMenuItem<String>(
//                                 value: school,
//                                 child: Text(
//                                   school,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ))
//                           .toList(),
//                       value: selectedSchool,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedSchool = value;
//                         });
//                       },
//                       dropdownStyleData: DropdownStyleData(
//                         maxHeight: 200,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(50.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                 ),
//                 child: const Text(
//                   'SUBMIT',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SchoolScreen extends StatefulWidget {
  @override
  _SchoolScreenState createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  final List<String> schoolNames = [
    'School A',
    'School B',
    'School C',
    'School D',
    'School E',
    'School F',
    'School G',
    'School H',
    'School I',
    'School J',
  ];

  String? selectedSchool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/cklogo.png',
            width: 200,
            height: 200,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: schoolNames.length,
                itemBuilder: (context, index) {
                  final school = schoolNames[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSchool = school;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/cklogo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            school,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // Add submit action here
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.black,
          //       ),
          //       child: const Text(
          //         'SUBMIT',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontFamily: 'Poppins',
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
