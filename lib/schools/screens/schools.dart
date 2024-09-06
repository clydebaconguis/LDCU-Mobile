// import 'package:flutter/material.dart';
// import 'package:pushtrial/schools/api/school_api.dart';
// import 'package:pushtrial/schools/models/schools.dart';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:pushtrial/auth/login.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SchoolScreen extends StatefulWidget {
//   @override
//   _SchoolScreenState createState() => _SchoolScreenState();
// }

// class _SchoolScreenState extends State<SchoolScreen> {
//   List<School> schoolNames = [];
//   String? selectedSchool;
//   String host = SchoolApi().getImage();

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     await getSchools();
//   }

//   Future<void> getSchools() async {
//     final response = await SchoolApi().getSchoolList();
//     Iterable list = json.decode(response.body);

//     setState(() {
//       schoolNames = list.map((model) => School.fromJson(model)).toList();
//       schoolNames.sort((a, b) => a.schoolname.compareTo(b.schoolname));
//     });
//   }

//   Future<void> _storeSelectedSchool(String eslink) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedSchool', eslink);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Image.asset(
//             'assets/cklogo.png',
//             width: 200,
//             height: 200,
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 1.0,
//                 ),
//                 itemCount: schoolNames.length,
//                 itemBuilder: (context, index) {
//                   final school = schoolNames[index];
//                   return GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         selectedSchool = school.eslink;
//                       });

//                       if (selectedSchool != null &&
//                           selectedSchool!.isNotEmpty) {
//                         await _storeSelectedSchool(selectedSchool!);

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => LoginScreen()),
//                         );
//                       } else {
//                         print('Selected school is null or empty.');
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ClipOval(
//                             child: CachedNetworkImage(
//                               imageUrl: "$host${school.schoollogo}",
//                               width: 80,
//                               height: 80,
//                               placeholder: (context, url) =>
//                                   CircularProgressIndicator(),
//                               errorWidget: (context, url, error) =>
//                                   Icon(Icons.error),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             school.schoolname,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pushtrial/schools/api/school_api.dart';
import 'package:pushtrial/schools/models/schools.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pushtrial/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolScreen extends StatefulWidget {
  @override
  _SchoolScreenState createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  List<School> schoolNames = [];
  List<School> filteredSchoolNames = [];
  String? selectedSchool;
  String host = SchoolApi().getImage();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    searchController.addListener(_filterSchools);
  }

  Future<void> _initializeData() async {
    await getSchools();
  }

  Future<void> getSchools() async {
    final response = await SchoolApi().getSchoolList();
    Iterable list = json.decode(response.body);

    setState(() {
      schoolNames = list.map((model) => School.fromJson(model)).toList();
      schoolNames.sort((a, b) => a.schoolname.compareTo(b.schoolname));
      filteredSchoolNames = schoolNames;
    });
  }

  void _filterSchools() {
    setState(() {
      filteredSchoolNames = schoolNames
          .where((school) => school.schoolname
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _storeSelectedSchool(String eslink) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSchool', eslink);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search School',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
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
                itemCount: filteredSchoolNames.length,
                itemBuilder: (context, index) {
                  final school = filteredSchoolNames[index];
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedSchool = school.eslink;
                      });

                      if (selectedSchool != null &&
                          selectedSchool!.isNotEmpty) {
                        await _storeSelectedSchool(selectedSchool!);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      } else {
                        print('Selected school is null or empty.');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: "$host${school.schoollogo}",
                              width: 80,
                              height: 80,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            school.schoolname,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
