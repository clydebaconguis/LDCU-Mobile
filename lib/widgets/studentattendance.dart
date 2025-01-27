import 'dart:convert';
import 'package:pushtrial/models/attendance.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendanceScreen> {
  String studid = '0';
  int syid = 0;
  String selectedYear = '';
  List<String> years = [];
  int id = 0;
  List<EnrollmentInfo> enInfoData = [];
  List<Attendance> attendance = [];

  bool loading = true;

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

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(studid).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();

        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        var lastindex = enInfoData[enInfoData.length - 1];
      });
    });
  }

  @override
  void initState() {
    getSchoolInfo();
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getUser();
    await getEnrollment();

    setState(() {
      loading = false;
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        studid = json;
      });
    }
  }

  Future<void> getStudentAttendance() async {
    final response = await CallApi().getStudentAttendance(studid, syid);

    if (response.body is List) {
      attendance = (response.body as List)
          .map((data) => Attendance.fromJson(data))
          .toList();
    } else if (response.body is String) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      attendance = (responseData['attendance_setup'] as List)
          .map((data) => Attendance.fromJson(data))
          .toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = attendance.fold(0, (sum, record) => sum + record.days);
    int totalPresent =
        attendance.fold(0, (sum, record) => sum + record.present);
    int totalAbsent = attendance.fold(0, (sum, record) => sum + record.absent);

    return loading
        ? Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: schoolColor,
              size: 100,
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField2<String>(
                  decoration: const InputDecoration(
                    labelText: 'School Year',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  value: null,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue!;

                      for (var yr in enInfoData) {
                        if (yr.sydesc == selectedYear) {
                          syid = yr.syid;
                          getStudentAttendance();
                        }
                      }
                    });
                  },
                  items: years.map<DropdownMenuItem<String>>((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(
                        year,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                    label: Text('Months',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 11,
                                        ))),
                                DataColumn(
                                    label: Text('No. of\nSchool\nDays',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 11,
                                        ))),
                                DataColumn(
                                    label: Text('No. of\nDays\nPresent',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 11,
                                        ))),
                                DataColumn(
                                    label: Text('No. of\nDays\nAbsent',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 11,
                                        ))),
                              ],
                              rows: [
                                ...attendance.map((Attendance record) {
                                  return DataRow(cells: [
                                    DataCell(Text(record.monthdesc,
                                        style: TextStyle(fontSize: 12))),
                                    DataCell(Text(record.days.toString(),
                                        style: TextStyle(fontSize: 11))),
                                    DataCell(Text(record.present.toString(),
                                        style: TextStyle(fontSize: 11))),
                                    DataCell(Text(record.absent.toString(),
                                        style: TextStyle(fontSize: 11))),
                                  ]);
                                }).toList(),
                                DataRow(
                                  cells: [
                                    const DataCell(Text(
                                      'TOTAL',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text(
                                      totalDays.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text(
                                      totalPresent.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text(
                                      totalAbsent.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }
}
