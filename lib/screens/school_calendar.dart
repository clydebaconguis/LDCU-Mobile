import 'dart:convert';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/event.dart';
import 'package:intl/intl.dart';
import 'package:pushtrial/models/school_info.dart';

class SchoolCalendar extends StatefulWidget {
  const SchoolCalendar({super.key});

  @override
  State<SchoolCalendar> createState() => _SchoolCalendarState();
}

class _SchoolCalendarState extends State<SchoolCalendar> {
  var id = '0';
  var syid = 0;
  String selectedYear = '';
  List<String> years = [];
  List<Event> events = [];
  List<EnrollmentInfo> enInfoData = [];
  late List<Appointment> _appointments = [];
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

  @override
  void initState() {
    getUser();
    getSchoolInfo();
    super.initState();
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

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrollment();
      await getEvents();
    }
    setState(() {
      loading = false;
    });
  }

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(id).then((response) {
      setState(() {
        Iterable list = jsonDecode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();
        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        for (var yr in enInfoData) {
          if (yr.sydesc == selectedYear) {
            syid = yr.syid;
            getEvents();
          }
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SCHOOL CALENDAR',
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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      labelText: 'School Year',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    isExpanded: true,
                    value: selectedYear.isNotEmpty ? selectedYear : null,
                    hint: Text(
                      'Choose a school year',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                        for (var yr in enInfoData) {
                          if (yr.sydesc == selectedYear) {
                            syid = yr.syid;
                            getEvents();
                          }
                        }
                      });
                    },
                    items: years.map<DropdownMenuItem<String>>(
                      (String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(
                            year,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  events.isNotEmpty
                      ? Expanded(
                          flex: 2,
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialSelectedDate: DateTime.now(),
                            dataSource: _AppointmentDataSource(_appointments),
                            appointmentBuilder: appointmentBuilder,
                            onTap: onTapCalendarCell,
                            specialRegions: _getSpecialRegions(),
                          ),
                        )
                      : Expanded(
                          flex: 2,
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialSelectedDate: DateTime.now(),
                            dataSource: _AppointmentDataSource(_appointments),
                            appointmentBuilder: appointmentBuilder,
                            onTap: onTapCalendarCell,
                            specialRegions: _getSpecialRegions(),
                          ),
                        ),
                  events.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              Event event = events[index];
                              String formattedDate = DateFormat('MMMM d, yyyy')
                                  .format(event.startTime);
                              // String formattedDateEnd =
                              //     DateFormat('MMMM d, yyyy')
                              //         .format(event.endTime);
                              return Card(
                                color: schoolColor,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        event.venue,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      // SizedBox(height: 5.0),
                                      // Text(
                                      //   formattedDateEnd,
                                      //   style: TextStyle(
                                      //     color: Colors.white,
                                      //     fontSize: 14.0,
                                      //   ),
                                      // ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        event.time,
                                        style: TextStyle(
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
                        )
                      : const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void onTapCalendarCell(CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          List<Event> events2 = details.appointments!.map((appointment) {
            return events.firstWhere((event) =>
                event.title == appointment.subject &&
                event.startTime == appointment.startTime &&
                event.endTime == appointment.endTime);
          }).toList();

          return AlertDialog(
            title: const Text('Event Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: events2.map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.venue),
                  trailing: Text(event.time),
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  Widget appointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    if (details.appointments.length == 1) {
      return Container(
        decoration: BoxDecoration(
          color: details.appointments.first.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            details.appointments.first.subject,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (details.appointments.length > 1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '+${details.appointments.length}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
