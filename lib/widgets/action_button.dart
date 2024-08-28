import 'package:flutter/material.dart';
import '../screens/billing_information.dart';
import '../screens/report_card.dart';
import '../screens//report_card_college.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/class_schedule.dart';
import '../screens/remedial_class.dart';
import 'dart:convert';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

  @override
  State<ActionButtons> createState() => ActionButtonsState();
}

class ActionButtonsState extends State<ActionButtons> {
  User user = UserData.myUser;
  String id = '0';
  String selectedSem = '';
  List<String> semesters = [];
  int syid = 0;
  int sectionid = 0;
  String sectionname = '';
  int levelid = 0;
  int semid = 0;
  String syDesc = '';
  String sem = '';
  String? selectedDay = '';
  String selectedMonth = '';
  String selectedYear = '';
  List<String> months = [];
  List<String> years = [];
  List<EnrollmentInfo> enInfoData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getUser();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ActionButton(
              icon: Icons.calendar_month,
              label: 'Class\nSchedule',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClassScheduleScreen()),
                );
              },
            ),
            ActionButton(
              icon: Icons.folder_open,
              label: 'Report\nCard',
              onPressed: () {
                EnrollmentInfo? latestInfo = getSelectedEnrollmentInfo();
                if (latestInfo != null) {
                  if (latestInfo.levelid >= 17) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReportCardCollege()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportCard()),
                    );
                  }
                }
              },
            ),
            ActionButton(
              icon: Icons.folder_open,
              label: 'Remedial\nClass',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RemedialClassScreen()),
                );
              },
            ),
            ActionButton(
              icon: Icons.receipt_long,
              label: 'Billing\nInformation',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BillingInformationPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
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
      }
    });
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key, required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: const Color.fromARGB(255, 133, 13, 22),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 68,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
