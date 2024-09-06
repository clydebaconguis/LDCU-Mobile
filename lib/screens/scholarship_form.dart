import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/scholarship.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ScholarshipFormScreen extends StatefulWidget {
  const ScholarshipFormScreen({super.key});
  @override
  State<ScholarshipFormScreen> createState() => ScholarshipFormScreenState();
}

class ScholarshipFormScreenState extends State<ScholarshipFormScreen> {
  User user = UserData.myUser;
  int studid = 0;
  List<ScholarshipSetup> _scholarshipSetup = [];
  List<Scholarship> _scholarship = [];
  List<Requirement> _requirement = [];
  int? selectedsetup;
  String? selectedrequirement;
  bool loading = true;
  Map<int, String?> selectedFiles = {};

  final TextEditingController _remarksController = TextEditingController();

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

  Future<void> selectFile(int requirementId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String fileName = result.files.single.name;
      setState(() {
        selectedFiles[requirementId] = fileName;
      });
      print('Selected file for requirement $requirementId: $fileName');
    } else {
      print('No file selected.');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });
    await getUser();
    await getScholarshipSetup();
    getSchoolInfo();
    setState(() {
      loading = false;
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    setState(() {
      studid = user.id;
    });
  }

  Future<void> getScholarshipSetup() async {
    final response = await CallApi().getScholarshipSetup();
    Iterable list = json.decode(response.body);
    setState(() {
      _scholarshipSetup =
          list.map((model) => ScholarshipSetup.fromJson(model)).toList();
    });
    print('Retrieved scholarship setup: $_scholarshipSetup');
  }

  Future<void> getRequirement() async {
    final response = await CallApi().getRequirement(selectedsetup!);
    Iterable list = json.decode(response.body);
    setState(() {
      _requirement = list.map((model) => Requirement.fromJson(model)).toList();
    });
    print('Retrieved requirement: $_requirement');
  }

  Future<void> _launchURL(String relativeUrl) async {
    final baseUrl = await CallApi().getDomain();
    final fullUrl = '$baseUrl$relativeUrl';

    print('Attempting to launch URL: $fullUrl');
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $fullUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCHOLARSHIP FORM',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: schoolColor,
                size: 100,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 30, right: 30, bottom: 30),
              child: Column(
                children: [
                  DropdownButtonFormField2<int>(
                    value: selectedsetup,
                    items: _scholarshipSetup
                        .map((option) => DropdownMenuItem(
                              child: Text(
                                option.description,
                                style: TextStyle(fontSize: 10),
                              ),
                              value: option.id,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedsetup = value;
                        print('Selected setup: $selectedsetup');
                        getRequirement();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name of Scholarship Applied for',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedsetup != null && _requirement.isNotEmpty)
                    Card(
                      child: Column(
                        children: _requirement
                            .map((req) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Document Name:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        req.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (req.fileurl.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            _launchURL(req.fileurl);
                                          },
                                          child: Text(
                                            'Download File Attachment',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () => selectFile(req.id),
                                        child: Text('Select File'),
                                      ),
                                      if (selectedFiles[req.id] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            ' ${selectedFiles[req.id]}',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  if (selectedsetup != null && _requirement.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _remarksController,
                            decoration: const InputDecoration(
                              labelText: 'Remarks',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: schoolColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
