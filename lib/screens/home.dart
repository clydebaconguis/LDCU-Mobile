import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import '../widgets/credit_card.dart';
import '../widgets/action_button.dart';
import '../widgets/tab_card.dart';
import '../models/user.dart';
import 'payment.dart';
import 'clearance.dart';
import 'school_calendar.dart';
import 'enrollment.dart';
import 'notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/taphistory.dart';
import 'package:pushtrial/models/smsbunker.dart';
// import 'package:pushtrial/main.dart';
import 'package:pushtrial/models/user_data.dart';
import 'dart:convert';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _notificationCount = 0;
  User user = UserData.myUser;
  late Future<void> _checkAndNotifyFuture;
  int studid = 0;
  int id = 0;
  String userFirstName = '';
  // List<TapHistory> data = [];
  String? notificationMessage;
  // late Timer _timer;
  List<String> notifications = [];
  List<SMS> sms = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkAndNotifyFuture = _initializeData();
    // _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
    //   _checkAndNotify();
    // });
  }

  Future<void> _initializeData() async {
    await getUser();
    await getSMSBunker();
    // await _checkAndNotify();
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    setState(() {});
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data: $user');
    {
      setState(() {
        studid = user.id!;
        userFirstName = user.firstname!;
      });
    }
  }

  // getTapHistory() async {
  //   try {
  //     final response = await CallApi().getTapHistory(studid);

  //     if (response.statusCode == 200) {
  //       if (response.body.isEmpty) {
  //         print('No data returned');
  //         return;
  //       }

  //       Iterable list = json.decode(response.body);
  //       setState(() {
  //         data = list.map((model) => TapHistory.fromJson(model)).toList();
  //         _notificationCount = data.where((tap) => tap.pushstatus == 1).length;
  //       });

  //       // print('Retrieved tap history: $data');
  //     } else {
  //       print(
  //           'Failed to load tap history. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }

  Future<void> getSMSBunker() async {
    try {
      final response = await CallApi().getSmsBunker(studid);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('No data returned');
          return;
        }

        Iterable list = json.decode(response.body);
        setState(() {
          sms = list.map((model) => SMS.fromJson(model)).toList();
          _notificationCount = sms.where((tap) => tap.pushstatus == 1).length;
        });

        print('Retrieved smsbunker $sms');
      } else {
        print('Failed to load smsnbunker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> updateNotificationPushStatus(id, studid, newStatus) async {
    final response = await CallApi().getUpdatePushStatus(id, studid, newStatus);

    if (response.statusCode == 200) {
      print('Notification push status updated successfully.');
    } else {
      print(
          'Failed to update notification push status. Status code: ${response.statusCode}');
    }
  }

  // Future<void> _checkAndNotify() async {
  //   try {
  //     if (data.isEmpty) {
  //       print('No tap history data to check.');
  //       return;
  //     }

  //     for (var tap in data) {
  //       if (tap.pushstatus == 0) {
  //         notificationMessage =
  //             "Hi! $userFirstName, your status has been updated.";
  //         await showNotification(userFirstName);

  //         print(
  //             'Updating push status for ID: ${tap.id}, Student ID: ${tap.studid}');

  //         final response = await CallApi()
  //             .getUpdatePushStatus(tap.id, tap.studid, 1, notificationMessage);
  //         if (response.statusCode == 200) {
  //           print('Push status updated successfully.');
  //         } else {
  //           print('Failed to update push status.');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }

  // Future<void> showNotification(String firstname) async {
  //   final String notificationMessage =
  //       "Hi! $firstname, your status has been updated.";
  //   // print(notificationMessage);

  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'Your channel description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );

  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'New Notification',
  //     notificationMessage,
  //     platformChannelSpecifics,
  //     payload: 'notifications_screen',
  //   );
  //   _handleNotification(notificationMessage);
  // }

  void _handleNotification(String message) {
    setState(() {
      notifications.add(message);
      _notificationCount = notifications.length;
    });
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstname', user.firstname ?? '');
    await prefs.setString('middlename', user.middlename ?? '');
    await prefs.setString('lastname', user.lastname ?? '');
    await prefs.setString('sid', user.sid ?? '');
    await prefs.setString('fathername', user.fathername ?? '');
  }

  Future<User> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return User(
      firstname: prefs.getString('firstname') ?? '',
      middlename: prefs.getString('middlename') ?? '',
      lastname: prefs.getString('lastname') ?? '',
      sid: prefs.getString('sid') ?? '',
      fathername: prefs.getString('fathername') ?? '',
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 133, 13, 22),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 133, 13, 22),
        leading: IconButton(
          icon: Image.asset('assets/app_icon.png'),
          color: Colors.white,
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            color: Colors.white,
            onPressed: () async {
              await saveUserData(user);

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user)),
              );
            },
          ),
          PopupMenuButton<SMS>(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 14, 19, 29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            offset: const Offset(0, 50),
            onSelected: (SMS selectedNotification) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Notification'),
                    content: Text(selectedNotification.message),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final updatedNotification = SMS(
                            id: selectedNotification.id,
                            studid: selectedNotification.studid,
                            pushstatus: 2,
                            receiver: selectedNotification.receiver,
                            message: selectedNotification.message,
                          );
                          setState(() {
                            sms = sms
                                .map((tap) => tap.id == updatedNotification.id
                                    ? updatedNotification
                                    : tap)
                                .toList();
                            _notificationCount =
                                sms.where((tap) => tap.pushstatus == 1).length;
                          });

                          await updateNotificationPushStatus(
                            updatedNotification.id,
                            updatedNotification.studid,
                            updatedNotification.pushstatus,
                          );

                          Navigator.of(context).pop();
                        },
                        child: const Text('Mark as Read'),
                      ),
                    ],
                  );
                },
              );
            },
            itemBuilder: (BuildContext context) {
              final filteredNotifications =
                  sms.where((tap) => tap.pushstatus == 1).toList();

              _notificationCount = filteredNotifications.length;

              return [
                ...filteredNotifications.map(
                  (notification) => PopupMenuItem<SMS>(
                    value: notification,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                      ),
                      child: Text(
                        notification.message,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<SMS>(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(
                              // onNotificationsViewed: () {
                              //   setState(() {});
                              // },
                              ),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'View All Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color.fromARGB(255, 109, 17, 10),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _checkAndNotifyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome Back!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  "${user.firstname} ${user.lastname}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 100.0),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Expanded(child: Container()),
                                const Center(
                                  // padding: EdgeInsets.only(bottom: 5.0),
                                  child: ActionButtons(),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TabCard(),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            left: 25,
                            right: 25,
                            child: CreditCard(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showMenu(context);
                },
                label: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                shape: const CircleBorder(),
                backgroundColor: const Color.fromARGB(255, 133, 13, 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    _animationController.forward();
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          height: 330,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildMenuRow(
                      iconData: [
                        Icons.school,
                        Icons.assessment,
                        Icons.calendar_today,
                      ],
                      labels: [
                        'Scholarship Request',
                        'Teacher Evaluation',
                        'School Calendar',
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    _buildMenuRow(
                      iconData: [
                        Icons.check_circle,
                        Icons.subscriptions,
                        Icons.payments,
                      ],
                      labels: [
                        'Clearance',
                        'Enrollment',
                        'Payment',
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 133, 13, 22),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _animationController.reverse();
    });
  }

  Widget _buildMenuRow({
    required List<IconData> iconData,
    required List<String> labels,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(iconData.length, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            return FadeTransition(
              opacity: _animationController.drive(
                Tween<double>(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: Interval(delay, 1.0, curve: Curves.easeIn)),
                ),
              ),
              child: SizeTransition(
                sizeFactor: _animationController.drive(
                  Tween<double>(begin: 0.0, end: 1.0).chain(
                    CurveTween(
                        curve: Interval(delay, 1.0, curve: Curves.easeIn)),
                  ),
                ),
                child: _buildMenuButton(
                    icon: iconData[index],
                    label: labels[index],
                    onPressed: () {
                      Navigator.pop(context);
                      if (labels[index] == 'Scholarship Request') {
                      } else if (labels[index] == 'School Calendar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SchoolCalendar()),
                        );
                      } else if (labels[index] == 'Clearance') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClearanceScreen()),
                        );
                      } else if (labels[index] == 'Enrollment') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EnrollmentScreen()),
                        );
                      } else if (labels[index] == 'Payment') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentPage()),
                        );
                      }
                    }),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundColor: const Color.fromARGB(255, 133, 13, 22),
          child: IconButton(
            icon: Icon(icon),
            color: Colors.white,
            onPressed: onPressed,
            iconSize: 30.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          constraints: const BoxConstraints(maxWidth: 80.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(user: User()),
  ));
}
