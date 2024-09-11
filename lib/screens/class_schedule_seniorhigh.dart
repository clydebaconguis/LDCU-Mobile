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

class ClassScheduleSeniorHighScreen extends StatefulWidget {
  const ClassScheduleSeniorHighScreen({super.key});

  @override
  State<ClassScheduleSeniorHighScreen> createState() =>
      _ClassScheduleSeniorHighScreenState();
}

class _ClassScheduleSeniorHighScreenState
    extends State<ClassScheduleSeniorHighScreen> {
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
  String selectedSem = '';
  List<String> months = [];
  List<String> years = [];
  List<SchedData> listOfSched = [];
  List<SchedItem> listOfItem2 = [];
  List<SchedItem> listOfItem3 = [];
  List<EnrollmentInfo> enInfoData = [];

  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
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
    schoolSem = (responseData['semester'] as List)
        .map((data) => Sem.fromJson(data))
        .toList();

    schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

    if (schoolYear.isNotEmpty && schoolSem.isNotEmpty) {
      selectedYear = schoolYear.first.id.toString();
      selectedSem = schoolSem.first.id.toString();
    }

    setState(() {});
  }

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(user.id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        print('enInfoData: $enInfoData');

        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();

        for (var yr in enInfoData) {
          setState(() {
            levelid = yr.levelid;
            sectionid = yr.sectionid;
          });

          break;
        }
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
    await getEnrollment();
    getSchedByMonth();

    setState(() {
      loading = false;
    });
  }

  Map<String, List<SchedItem>> _groupItemsByDay(List<SchedItem> items) {
    Map<String, List<SchedItem>> groupedItems = {};

    for (var item in items) {
      if (!groupedItems.containsKey(item.month)) {
        groupedItems[item.month] = [];
      }
      groupedItems[item.month]!.add(item);
    }

    return groupedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CLASS SCHEDULE SENIOR HIGH',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: schoolColor,
            )),
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
                  left: 30.0, top: 10.0, right: 30.0, bottom: 30.0),
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
                      const SizedBox(width: 10.0),
                      if (levelid >= 14) ...[
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            value: selectedSem,
                            items: schoolSem
                                .map((option) => DropdownMenuItem(
                                      child: Text(
                                        option.semester,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      value: option.id.toString(),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSem = value!;
                                semid = int.parse(selectedSem);
                              });
                              if (selectedYear.isNotEmpty) {
                                getStudSchedule(int.parse(selectedSem));
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Semester',
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
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
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
                    items: months.map<DropdownMenuItem<String>>(
                      (String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: ListView.builder(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  color: schoolColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              '${item.subject}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontFamily: 'Poppins',
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                              Icon(Icons.person, size: 16),
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
                                            Icon(Icons.access_time, size: 16),
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
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
