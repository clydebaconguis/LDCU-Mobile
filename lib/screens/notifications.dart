import 'package:flutter/material.dart';
import 'package:pushtrial/push_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';
import 'package:pushtrial/models/taphistory.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class NotificationsScreen extends StatefulWidget {
  // final VoidCallback onNotificationsViewed;

  // NotificationsScreen({required this.onNotificationsViewed});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  User user = UserData.myUser;
  int studid = 0;
  List<TapHistory> data = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    await getTapHistory();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data in notifications screen: $user');

    setState(() {
      studid = user.id ?? 0;
    });
  }

  Future<void> getTapHistory() async {
    try {
      final response = await CallApi().getTapHistory(studid);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('No data returned');
          return;
        }

        Iterable list = json.decode(response.body);
        setState(() {
          data = list.map((model) => TapHistory.fromJson(model)).toList();
        });

        print('Retrieved tap history for notifications: $data');
      } else {
        print(
            'Failed to load tap history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> updateNotificationPushStatus(
      id, studid, newStatus, message) async {
    final response =
        await CallApi().getUpdatePushStatus(id, studid, newStatus, message);

    if (response.statusCode == 200) {
      print('Notification push status updated successfully.');
    } else {
      print(
          'Failed to update notification push status. Status code: ${response.statusCode}');
    }
  }

  Future<void> _showFCMTokenDialog() async {
    String? token = await PushNotifications.getFCMToken();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('FCM Token'),
          content: Text(token ?? 'Failed to retrieve FCM token'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TapHistory> filteredData =
        data.where((item) => item.pushstatus == 2).toList();

    filteredData.sort((a, b) {
      int dateComparison = b.tdate.compareTo(a.tdate);
      if (dateComparison == 0) {
        return b.ttime.compareTo(a.ttime);
      }
      return dateComparison;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: filteredData.isEmpty
            ? Center(child: Text('No notifications available'))
            : ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final notification = filteredData[index];
                  return SwipeActionCell(
                    key: ValueKey(notification.id),
                    trailingActions: [
                      SwipeAction(
                        content: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Mark as Read",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: (CompletionHandler handler) async {
                          await handler(true);
                          await updateNotificationPushStatus(
                              notification.id, studid, 3, notification.message);
                          setState(() {
                            data.removeAt(index);
                          });
                        },
                        color: const Color.fromARGB(255, 14, 19, 29),
                      ),
                    ],
                    child: Card(
                      color: const Color.fromARGB(255, 109, 17, 10),
                      margin: const EdgeInsets.all(10.0),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          notification.message,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${notification.tdate} ${notification.ttime}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFCMTokenDialog,
        child: Icon(Icons.info),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
