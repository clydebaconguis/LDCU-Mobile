import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/schedule.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  User user = UserData.myUser;
  String id = '0';

  List<String> semesters = [];
  int syid = 0;
  int sectionid = 0;
  String sectionname = '';
  int levelid = 0;
  int semid = 0;
  String? selectedDay = '';
  String selectedMonth = '';
  String selectedYear = '';
  List<String> months = [];
  List<String> years = [];
  List<SchedData> listOfSched = [];
  List<SchedItem> listOfItem2 = [];
  List<SchedItem> listOfItem3 = [];
  List<EnrollmentInfo> enInfoData = [];
  List<SchoolYear> schoolYear = [];
  List<EnrolledStud> enrolledstud = [];

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

  getSchedByMonth() {
    Set<String> uniqueSet = months.toSet();
    months = uniqueSet.toList();
    if (selectedMonth.isEmpty) {
      return;
    } else {
      listOfItem3.clear();
      for (var element in listOfItem2) {
        if (element.month.contains(selectedMonth)) {
          setState(() {
            listOfItem3.add(
              SchedItem(
                month: element.month,
                start: element.start,
                end: element.end,
                subject: element.subject,
                room: element.room,
                teacher: element.teacher,
              ),
            );
          });
        }
      }
    }
  }

  getStudSchedule(int index) async {
    months.clear();
    selectedMonth = '';
    listOfItem2.clear();
    List<SchedItem> listOfItem = [];
    await CallApi()
        .getSchedule(user.id, syid, index, sectionid, levelid)
        .then((response) {
      Iterable list = json.decode(response.body);

      setState(() {
        for (var element in list) {
          var ll = element['schedule'];

          for (var el in ll) {
            listOfItem.clear();
            if (el['day'] != null && el['sched'] != null) {
              var sched = el['sched'];

              if (sched.isNotEmpty || sched != null) {
                for (var item in sched) {
                  if (item['start'] != null) {
                    var start = item['start'] ?? '';
                    var end = item['end'] ?? '';
                    var subject = item['subject'] ?? '';
                    var room = item['room'] ?? '';
                    var teacher = item['teacher'] ?? '';
                    listOfItem.add(
                      SchedItem(
                          month: el['day'],
                          start: start,
                          end: end,
                          subject: subject,
                          room: room,
                          teacher: teacher),
                    );
                    listOfItem2.add(
                      SchedItem(
                          month: el['day'],
                          start: start,
                          end: end,
                          subject: subject,
                          room: room,
                          teacher: teacher),
                    );
                  }
                }
                months.add(el['day']);
              }
            }
            listOfSched.add(SchedData(day: el['day'], sched: listOfItem));
          }

          semid = index;

          selectedMonth = listOfSched[0].day;

          getSchedByMonth();
        }
      });
    });
  }

  getYearandSem() async {
    final response = await CallApi().getYearandSem();
    final Map<String, dynamic> responseData = json.decode(response.body);

    schoolYear = (responseData['sy'] as List)
        .map((data) => SchoolYear.fromJson(data))
        .toList();

    schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

    if (schoolYear.isNotEmpty) {
      selectedYear = schoolYear.first.id.toString();
    }

    setState(() {});
  }

  // getEnrollment() async {
  //   await CallApi().getEnrollmentInfo(user.id).then((response) {
  //     setState(() {
  //       Iterable list = json.decode(response.body);

  //       enInfoData = list.map((model) {
  //         return EnrollmentInfo.fromJson(model);
  //       }).toList();

  //       for (var element in enInfoData) {
  //         years.add(element.sydesc);
  //         semesters.add(element.semester);
  //       }
  //       Set<String> uniqueSet = years.toSet();
  //       years = uniqueSet.toList();
  //       selectedYear = enInfoData[enInfoData.length - 1].sydesc;
  //       selectedSem = semesters.isNotEmpty ? semesters[0] : '';
  //       for (var yr in enInfoData) {
  //         if (yr.sydesc == selectedYear) {
  //           setState(() {
  //             syid = yr.syid;
  //             semid = 1;
  //             sectionid = yr.sectionid;
  //             levelid = yr.levelid;
  //           });
  //           getStudSchedule(1);
  //           break;
  //         }
  //       }
  //     });
  //   });
  // }

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(user.id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        // print('enInfoData: $enInfoData');

        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();
      });
    });
  }

  getEnrolledStud() async {
    await CallApi().getEnrolledStud(user.id).then((response) {
      setState(() {
        var decodedJson = json.decode(response.body);

        if (decodedJson is Map<String, dynamic>) {
          Iterable list = decodedJson['enrolledstud_info'];
          enrolledstud =
              list.map((model) => EnrolledStud.fromJson(model)).toList();
        }

        print('enrolledstud: $enrolledstud');
      });
    });
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');

    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
  }

  EnrollmentInfo? getSelectedEnrollmentInfo() {
    if (selectedYear.isEmpty) return null;

    return enInfoData.firstWhere(
      (enrollment) => enrollment.sydesc.contains(selectedYear),
      orElse: () => EnrollmentInfo(
        sydesc: '',
        levelname: '',
        sectionname: '',
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
        courseDesc: '',
      ),
    );
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
    await getSchoolInfo();
    await getYearandSem();
    await getEnrolledStud();
    // await getEnrollment();
    getSchedByMonth();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CLASS SCHEDULE',
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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField2<String>(
                          value: selectedYear,
                          items: schoolYear
                              .map((option) => DropdownMenuItem(
                                    child: Text(
                                      option.sydesc,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: option.id.toString(),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value!;
                              syid = int.parse(selectedYear);
                              selectedMonth = '';
                              months = [];

                              EnrolledStud? student = enrolledstud.firstWhere(
                                (stud) => stud.syid == syid,
                                orElse: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "No Schedule for this School Year",
                                      ),
                                    ),
                                  );

                                  return EnrolledStud(
                                    id: 0,
                                    studid: 0,
                                    syid: 0,
                                    levelid: 0,
                                    sectionid: 0,
                                    studstatus: 0,
                                  );
                                },
                              );

                              listOfItem3.clear();

                              if (student.levelid != 0 &&
                                  student.sectionid != 0) {
                                levelid = student.levelid;
                                sectionid = student.sectionid;
                                getStudSchedule(syid);
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'School Year',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Day',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    isExpanded: true,
                    value: selectedMonth,
                    hint: const Text(
                      'Choose a day',
                      style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                        getSchedByMonth();
                      });
                    },
                    items: months.map<DropdownMenuItem<String>>((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          month,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: listOfItem3.isNotEmpty
                        ? ListView.builder(
                            itemCount: listOfItem3.length,
                            itemBuilder: (context, index) {
                              final item = listOfItem3[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        color: schoolColor,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Text(
                                                    '${item.subject}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              if (item.teacher.isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(Icons.person,
                                                        size: 16),
                                                    SizedBox(width: 8.0),
                                                    Text(
                                                      item.teacher,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              if (item.room.isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(Icons.meeting_room,
                                                        size: 16),
                                                    SizedBox(width: 8.0),
                                                    Text(
                                                      item.room,
                                                      style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time,
                                                      size: 16),
                                                  SizedBox(width: 8.0),
                                                  Text(
                                                    '${item.start} - ${item.end}',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Image.asset(
                              'assets/bell.png',
                              height: 200,
                              width: 200,
                            ),
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
