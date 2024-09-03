import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrollment_info.dart';

import 'package:pushtrial/models/schedule.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ClassScheduleCollegeScreen extends StatefulWidget {
  const ClassScheduleCollegeScreen({super.key});

  @override
  State<ClassScheduleCollegeScreen> createState() =>
      _ClassScheduleCollegeScreenState();
}

class _ClassScheduleCollegeScreenState
    extends State<ClassScheduleCollegeScreen> {
  User user = UserData.myUser;
  String id = '0';
  String selectedSem = '';
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

  bool loading = true;

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

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(user.id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
          semesters.add(element.semester);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();
        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        selectedSem = semesters.isNotEmpty ? semesters[0] : '';
        for (var yr in enInfoData) {
          if (yr.sydesc == selectedYear) {
            setState(() {
              syid = yr.syid;
              semid = 1;
              sectionid = yr.sectionid;
              levelid = yr.levelid;
            });
            getStudSchedule(1);
            break;
          }
        }
      });
    });
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    setState(() {
      loading = true;
    });
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    await getEnrollment();

    await getSchedByMonth();
    {
      setState(() {
        loading = false;
      });
    }
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
      ),
    );
  }

  @override
  void initState() {
    getUser();
    super.initState();
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
        title: const Text('CLASS SCHEDULE',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'School Year',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          isExpanded: true,
                          hint: const Text(
                            'Choose a school year',
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                          items: years
                              .map((year) => DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: years.contains(selectedYear)
                              ? selectedYear
                              : null,
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value ?? '';
                              for (var yr in enInfoData) {
                                if (yr.sydesc == selectedYear) {
                                  syid = yr.syid;
                                  sectionid = yr.sectionid;
                                  levelid = yr.levelid;
                                  selectedMonth = listOfItem2.isNotEmpty
                                      ? listOfItem2[0].month
                                      : '';
                                  getStudSchedule(1);
                                  break;
                                }
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      if (levelid == 14 || levelid == 15 || levelid >= 17) ...[
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Semester',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            isExpanded: true,
                            hint: const Text(
                              'Choose a semester',
                              style: TextStyle(
                                  fontSize: 14, fontFamily: 'Poppins'),
                            ),
                            items: semesters
                                .map((semester) => DropdownMenuItem<String>(
                                      value: semester,
                                      child: Text(
                                        semester,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: semesters.contains(selectedSem)
                                ? selectedSem
                                : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSem = newValue ?? '';
                                for (var each in enInfoData) {
                                  if (each.semester == newValue) {
                                    semid = each.semid;
                                    syid = each.syid;
                                    sectionid = each.sectionid;
                                    levelid = each.levelid;
                                    getStudSchedule(each.semid);
                                    break;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Expanded(
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.vertical,
                  //     child: Column(
                  //       children:
                  //           _groupItemsByDay(listOfItem2).entries.map((entry) {
                  //         return Card(
                  //           color: Colors.white,
                  //           elevation: 2.0,
                  //           child: Padding(
                  //             padding: EdgeInsets.all(16.0),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   entry.key,
                  //                   style: TextStyle(
                  //                       fontFamily: 'Poppins',
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //                 SizedBox(height: 10.0),
                  //                 ...entry.value.map((item) {
                  //                   return Column(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Text(
                  //                         item.subject,
                  //                         style: TextStyle(
                  //                             fontFamily: 'Poppins',
                  //                             fontSize: 14,
                  //                             fontWeight: FontWeight.bold),
                  //                         overflow: TextOverflow.clip,
                  //                         maxLines: 2,
                  //                       ),
                  //                       SizedBox(height: 4.0),
                  //                       if (item.room.isNotEmpty)
                  //                         Row(
                  //                           children: [
                  //                             Icon(Icons.meeting_room,
                  //                                 size: 16),
                  //                             SizedBox(width: 8.0),
                  //                             Text(
                  //                               item.room,
                  //                               style: TextStyle(
                  //                                   fontFamily: 'Poppins',
                  //                                   fontSize: 12,
                  //                                   color: Colors.grey),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       SizedBox(height: 4.0),
                  //                       Row(
                  //                         children: [
                  //                           Icon(Icons.access_time, size: 16),
                  //                           SizedBox(width: 8.0),
                  //                           Text(
                  //                             '${item.start} - ${item.end}',
                  //                             style: TextStyle(
                  //                               fontFamily: 'Poppins',
                  //                               fontSize: 12,
                  //                               color: Colors.grey,
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                       SizedBox(height: 4.0),
                  //                       if (item.teacher.isNotEmpty)
                  //                         Row(
                  //                           children: [
                  //                             Icon(Icons.person, size: 16),
                  //                             SizedBox(width: 8.0),
                  //                             Text(
                  //                               item.teacher,
                  //                               style: TextStyle(
                  //                                 fontFamily: 'Poppins',
                  //                                 fontSize: 12,
                  //                                 color: Colors.grey,
                  //                               ),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       SizedBox(height: 25.0),
                  //                     ],
                  //                   );
                  //                 }).toList(),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ),
                  // ),

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
                            // borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  color: const Color.fromARGB(255, 133, 13, 22),
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
                                                // fontWeight: FontWeight.bold,
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
      // floatingActionButton: ClipOval(
      //   child: Material(
      //     color: const Color.fromARGB(255, 133, 13, 22).withOpacity(0.8),
      //     child: InkWell(
      //       splashColor: const Color.fromARGB(255, 133, 13, 22),
      //       onTap: () {},
      //       child: const SizedBox(
      //         width: 56,
      //         height: 56,
      //         child: Icon(Icons.print, color: Colors.white),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
