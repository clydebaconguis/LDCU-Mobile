import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/enrollment_data.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => EnrollmentScreenState();
}

class EnrollmentScreenState extends State<EnrollmentScreen> {
  User user = UserData.myUser;
  String id = '0';
  int syid = 0;
  int sectionid = 0;
  String sectionname = '';
  int levelid = 0;
  int semid = 1;
  String selectedYear = '';
  String? selectedDay = '';
  String selectedMonth = '';
  String selectedSem = '';
  List<String> months = [];
  List<String> years = [];
  List<String> semesters = [];
  List<EnrollmentInfo> enInfoData = [];
  List<EnrollmentData> enData = [];
  String syDesc = '';
  String sem = '';

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getUser();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENROLLMENT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: const Color.fromARGB(255, 133, 13, 22),
                size: 100,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 250,
                ),
                child: Card(
                  color: const Color.fromARGB(255, 133, 13, 22),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Enrollment Information',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _buildInfoRow('School Year', selectedYear),
                        _buildInfoRow('Enrollment Status', _getStatus()),
                        _buildInfoRow('Grade Level', _getGradeLevel()),
                        if (_getSection() != 'Not Found')
                          _buildInfoRow('Section', _getSection()),
                        if (_getCourse().isNotEmpty)
                          _buildInfoRow('Course', _getCourse()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeLevel() {
    final latestInfo = getSelectedEnrollmentInfo();
    return latestInfo?.levelname ?? 'Not Available';
  }

  String _getSection() {
    final latestInfo = getSelectedEnrollmentInfo();
    return latestInfo?.sectionname ?? 'Not Found';
  }

  String _getStatus() {
    final latestInfo = getSelectedEnrollmentData();
    return latestInfo?.studstatus ?? '';
  }

  String _getCourse() {
    final latestInfo = getSelectedEnrollmentData();
    return latestInfo?.courseDesc ?? '';
  }

  EnrollmentInfo? getSelectedEnrollmentInfo() {
    if (selectedYear.isEmpty) return null;

    return enInfoData.firstWhere(
      (enrollment) => enrollment.sydesc.contains(selectedYear),
      orElse: () => EnrollmentInfo(
        sydesc: '',
        levelname: '',
        sectionname: 'Not Found',
        semid: 0,
        dateenrolled: '',
        syid: 0,
        levelid: 0,
        sectionid: 0,
        isactive: 0,
        strandid: 0,
        semester: '',
        strandcode: '',
        courseabrv: '',
      ),
    );
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrollment();
      await getEnrollData();
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');

    setState(() {
      user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    });
  }

  Future<void> getEnrollment() async {
    final response = await CallApi().getEnrollmentInfo(id);
    setState(() {
      Iterable list = json.decode(response.body);
      enInfoData = list.map((model) => EnrollmentInfo.fromJson(model)).toList();

      if (enInfoData.isNotEmpty) {
        selectedYear = enInfoData.last.sydesc;
        syDesc = selectedYear;

        var latestInfo =
            enInfoData.firstWhere((element) => element.sydesc == selectedYear,
                orElse: () => EnrollmentInfo(
                      sydesc: '',
                      levelname: '',
                      sectionname: 'Not Found',
                      semid: 0,
                      dateenrolled: '',
                      syid: 0,
                      levelid: 0,
                      sectionid: 0,
                      isactive: 0,
                      strandid: 0,
                      semester: '',
                      strandcode: '',
                      courseabrv: '',
                    ));
        sem = latestInfo.semester;
        syid = latestInfo.syid;
        sectionid = latestInfo.sectionid;
        levelid = latestInfo.levelid;
      }
    });
  }

  Future<void> getEnrollData() async {
    // print(
    //     'Requesting enrollment data with id: $id, syid: $syid, semid: $semid');
    final response = await CallApi().getEnrollmentData(id, syid, semid);

    // print('Raw Response Body: ${response.body}');

    try {
      final responseBody = response.body;
      if (responseBody == null || responseBody.isEmpty) {
        print('Response body is null or empty');
        return;
      }

      final responseJson = json.decode(responseBody);

      // print('Decoded Response JSON: $responseJson');

      if (responseJson is Map) {
        final enrollmentData = EnrollmentData.fromJson(responseJson);

        setState(() {
          enData = [enrollmentData];

          selectedYear = enrollmentData.sydesc;
          syDesc = selectedYear;

          var latestInfo = enData.firstWhere(
            (element) => element.sydesc == selectedYear,
            orElse: () => EnrollmentData(
              sydesc: '',
              levelname: '',
              semid: 0,
              syid: 0,
              levelid: 0,
              sectionid: 0,
              courseabrv: '',
              studstatus: '',
              semdesc: '',
              nationality: '',
              courseDesc: '',
            ),
          );

          syid = latestInfo.syid;
          sectionid = latestInfo.sectionid;
          levelid = latestInfo.levelid;

          // print('Selected Enrollment Data: ${latestInfo.toJson()}');
        });
      } else {
        print('Unexpected response format');
      }
    } catch (e) {
      print('Error parsing enrollment data: $e');
    }
  }

  EnrollmentData? getSelectedEnrollmentData() {
    if (selectedYear.isEmpty) return null;

    return enData.firstWhere(
      (enrollment) => enrollment.sydesc.contains(selectedYear),
      orElse: () => EnrollmentData(
        sydesc: '',
        levelname: '',
        semid: 0,
        syid: 0,
        levelid: 0,
        sectionid: 0,
        courseabrv: '',
        studstatus: '',
        semdesc: '',
        nationality: '',
        courseDesc: '',
      ),
    );
  }

  objectsToJson(List<EnrollmentData> enData) {}
}

void main() {
  runApp(const MaterialApp(
    home: EnrollmentScreen(),
  ));
}
