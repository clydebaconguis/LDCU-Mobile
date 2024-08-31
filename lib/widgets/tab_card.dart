import 'package:flutter/material.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/schedule.dart';
import 'package:pushtrial/models/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class TabCard extends StatefulWidget {
  const TabCard({super.key});

  @override
  State<TabCard> createState() => TabCardState();
}

class TabCardState extends State<TabCard> {
  User user = UserData.myUser;
  String id = '0';
  String sid = '0';
  int syid = 1;
  int semid = 1;
  int sectionid = 0;
  int levelid = 0;
  String selectedYear = '';
  List<EnrollmentInfo> enInfoData = [];
  String selectedMonth = '';
  String selectedSem = '';
  List<String> semesters = [];
  List<String> months = [];
  List<String> years = [];
  List<SchedData> listOfSched = [];
  List<SchedItem> listOfItem2 = [];
  List<SchedItem> listOfItem3 = [];
  late List<Appointment> _appointments = [];
  List<Event> events = [];
  String syDesc = '';
  String sem = '';

  @override
  void initState() {
    super.initState();
    getUser();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, left: 8.0, right: 8.0),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ContainedTabBarView(
          tabs: [
            _buildTab(Icons.subscriptions, "Enrollment"),
            _buildTab(Icons.class_, "Class Schedule"),
            _buildTab(Icons.calendar_today, "Calendar"),
          ],
          views: [
            _buildTabContentEnrollment(),
            _buildTabContentClass(),
            _buildTabContentCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 133, 13, 22)),
        const SizedBox(height: 4.0),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Color.fromARGB(255, 133, 13, 22),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContentEnrollment() {
    if (enInfoData.isEmpty) {
      return Container(
        child: const Text(
          "Loading...Please check internet connection",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      );
    }

    final latestInfo =
        enInfoData.firstWhere((element) => element.sydesc == selectedYear);

    final sectionText = latestInfo.sectionname != "Not Found"
        ? "Section: ${latestInfo.sectionname}\n"
        : '';
    final courseText = latestInfo.courseabrv.isNotEmpty
        ? "Course: ${latestInfo.courseabrv}\n"
        : '';

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Card(
        color: const Color.fromARGB(255, 14, 19, 29),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "ID No: ${user.sid}\n"
            "Grade Level: ${latestInfo.levelname}\n"
            "$sectionText"
            "$courseText",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContentClass() {
    if (listOfItem3.isEmpty) {
      return const Center(
        child: Text(
          "No classes scheduled for today.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ListView.builder(
        itemCount: listOfItem3.length,
        itemBuilder: (context, index) {
          final schedItem = listOfItem3.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              color: const Color.fromARGB(255, 133, 13, 22),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedItem.room,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: const Color.fromARGB(255, 14, 19, 29),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedItem.subject,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Teacher: ${schedItem.teacher}",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Time: ${schedItem.start} - ${schedItem.end}",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _buildTabContentCalendar() {
    DateTime now = DateTime.now();
    List<Event> futureEvents =
        events.where((event) => event.startTime.isAfter(now)).toList();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ListView.builder(
        itemCount: futureEvents.length,
        itemBuilder: (context, index) {
          Event event = futureEvents[index];
          String formattedDate =
              DateFormat('MMMM d, yyyy').format(event.startTime);
          return Card(
            color: const Color.fromARGB(255, 133, 13, 22),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    event.venue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    event.time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
      });
      await getEnrollment();
    }
    setState(() {});
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    setState(() {});
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    await getEnrollment();
    await getStudSchedule;
    await getSchedByMonth();
    {
      setState(() {});
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

  String getCurrentDay() {
    DateTime now = DateTime.now();
    List<String> daysOfWeek = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    return daysOfWeek[now.weekday % 7];
  }

  getSchedByMonth() {
    Set<String> uniqueSet = months.toSet();
    months = uniqueSet.toList();

    if (selectedMonth.isEmpty) {
      return null;
    } else {
      listOfItem3.clear();
      String currentDay = getCurrentDay();
      for (var element in listOfItem2) {
        if (element.month == currentDay) {
          if (!listOfItem3.any((item) =>
              item.subject == element.subject &&
              item.start == element.start &&
              item.end == element.end)) {
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
  }

  getStudSchedule(int index) async {
    months.clear();
    selectedMonth = '';
    listOfItem2.clear();
    List<SchedItem> listOfItem = [];

    try {
      final response =
          await CallApi().getSchedule(user.id, syid, index, sectionid, levelid);
      Iterable list = json.decode(response.body);

      setState(() {
        listOfSched.clear();

        for (var element in list) {
          var ll = element['schedule'] ?? [];

          for (var el in ll) {
            if (el['day'] != null && el['sched'] != null) {
              var sched = el['sched'];
              // print('Schedule for day ${el['day']}: $sched');

              if (sched.isNotEmpty) {
                for (var item in sched) {
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
                months.add(el['day']);
              }
              listOfSched.add(SchedData(day: el['day'], sched: listOfItem));
            }
          }

          semid = index;
          selectedMonth = listOfSched.isNotEmpty ? listOfSched[0].day : '';
          getSchedByMonth();
        }
      });
    } catch (e) {
      print('Error fetching schedule: $e');
    }
  }

  List<Appointment> _getAppointments() {
    return events.map((event) {
      return Appointment(
        startTime: event.startTime,
        endTime: event.endTime,
        subject: event.title,
        color: Colors.blue,
      );
    }).toList();
  }

  List<TimeRegion> _getSpecialRegions() {
    List<TimeRegion> specialRegions = [];

    for (Appointment appointment in _appointments) {
      specialRegions.add(TimeRegion(
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        enablePointerInteraction: false,
        textStyle: const TextStyle(color: Colors.white),
        color: Colors.blue,
      ));
    }

    return specialRegions;
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
            getEvents();
            break;
          }
        }

        var latestInfo =
            enInfoData.firstWhere((element) => element.sydesc == selectedYear);
        syid = latestInfo.syid;
        semid = latestInfo.semid;

        syDesc = selectedYear;
        sem = latestInfo.semester;
      });
    });
  }

  getEvents() async {
    await CallApi().getEvents(syid).then((response) {
      setState(() {
        Iterable ll = jsonDecode(response.body);
        events = (ll as List<dynamic>).map((e) {
          return Event(
            id: e['id'],
            title: e['title'],
            venue: e['venue'],
            startTime: DateTime.parse(e['startTime']),
            endTime: DateTime.parse(e['endTime']),
            time: e['time'],
          );
        }).toList();
        _appointments = _getAppointments();
      });
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: TabCard(),
    ),
  ));
}
