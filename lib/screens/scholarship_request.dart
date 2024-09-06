import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'scholarship_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/scholarship.dart';

class ScholarshipRequestScreen extends StatefulWidget {
  const ScholarshipRequestScreen({super.key});
  @override
  State<ScholarshipRequestScreen> createState() =>
      ScholarshipRequestScreenState();
}

class ScholarshipRequestScreenState extends State<ScholarshipRequestScreen> {
  User user = UserData.myUser;
  int studid = 0;

  List<Scholarship> _scholarship = [];

  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> getSchoolInfo() async {
    final response = await CallApi().getSchoolInfo();

    final parsedResponse = json.decode(response.body);
    if (parsedResponse is List) {
      setState(() {
        schoolInfo = parsedResponse
            .map((model) => SchoolInfo.fromJson(model))
            .toList()
            .cast<SchoolInfo>();

        schoolColor = hexToColor(schoolInfo[0].schoolcolor);
      });
    }
  }

  @override
  void initState() {
    getSchoolInfo();
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    await getScholarship();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    // print('User data in scholarship section screen: $user');

    setState(() {
      studid = user.id;
    });
  }

  Future<void> getScholarship() async {
    final response = await CallApi().getScholarship(studid);
    Iterable list = json.decode(response.body);
    setState(() {
      _scholarship = list.map((model) => Scholarship.fromJson(model)).toList();
    });
    print('Retrieved scholarship: $_scholarship');
  }

  Future<void> getDeleteScholarship(id) async {
    final response = await CallApi().getDeleteScholarship(id);

    if (response.statusCode == 200) {
      print('Scholarship deleted successfully');
    } else {
      print(
          'Failed to delete scholarship. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCHOLARSHIP REQUEST',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView.builder(
          itemCount: _scholarship.length,
          itemBuilder: (context, index) {
            final scholarship = _scholarship[index];
            final formattedDate =
                dateFormat.format(DateTime.parse(scholarship.createddatetime));

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.all(7.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   formattedDate,
                        //   style: const TextStyle(
                        //     fontFamily: 'Poppins',
                        //     fontSize: 10,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        const SizedBox(height: 4),
                        Text(
                          scholarship.description,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              scholarship.studstatus,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              scholarship.scholar_status,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: FloatingActionButton(
                            heroTag: 'edit_$index',
                            mini: true,
                            backgroundColor: Colors.blue,
                            onPressed: () {},
                            child: const Icon(Icons.edit, size: 16),
                            shape: const CircleBorder(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: FloatingActionButton(
                            heroTag: 'delete_$index',
                            backgroundColor: Colors.red,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Deletion',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        textAlign: TextAlign.center),
                                    content: Text(
                                        'Are you sure you want to delete this scholarship request?',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                        )),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await getDeleteScholarship(
                                              scholarship.id);
                                          setState(() {
                                            scholarship.deleted = 1;
                                            _scholarship.removeAt(index);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Delete'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(Icons.delete, size: 16),
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: ClipOval(
        child: Material(
          color: schoolColor,
          child: InkWell(
            splashColor: schoolColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScholarshipFormScreen()),
              );
            },
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
