import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pushtrial/main.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/user_login.dart';
import 'package:pushtrial/models/login.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/taphistory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static User user = UserData.myUser;
  static Login userLogin = UserDataLogin.myUserLogin;
  static int? studid;
  static int? type;
  static String? userFirstName;
  static List<TapHistory>? data;

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    getFCMToken();
    await getUser();
    await getLogin();
    getTapHistory();
  }

  static Future getFCMToken({int maxRetries = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _firebaseMessaging.getToken(
            vapidKey:
                "BJzRufH-VxRc7wLunA6WOaf-gVurFKhDluPRFB8644PQHw6OfWH8uzybtYsFBTA326_yy3PEG-L7OK_ojVsMmrI");
        print("for web device token: $token");
      } else {
        token = await _firebaseMessaging.getToken();
        print("for android/ios device token: $token");
      }

      if (token != null) {
        await getSaveFcmToken(token);
      }
      return token;
    } catch (e) {
      print("Failed to get device token, check internet connection");
      if (maxRetries > 0) {
        print("Retrying after 10 seconds");
        await Future.delayed(Duration(seconds: 10));
        return getFCMToken(maxRetries: maxRetries - 1);
      } else {
        return null;
      }
    }
  }

  static Future getSaveFcmToken(String token) async {
    if (studid == null) {
      print('Student ID is not set.');
      return;
    }

    try {
      final response = await CallApi().getSaveToken(studid!, type!, token);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Token saved successfully');
      } else {
        print('Failed to save token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed("/notifications", arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your_channel_id', 'Essentiel',
            channelDescription: 'Essentiel Notifications',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  static Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data in push notifications: $user');

    studid = user.id;
    userFirstName = user.firstname;
  }

  static Future getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('userlogin');
    userLogin = json == null
        ? UserDataLogin.myUserLogin
        : Login.fromJson(jsonDecode(json));
    print('User login data in push notifications: $userLogin');

    type = userLogin.type;
  }

  static Future getTapHistory() async {
    if (studid == null) {
      print('Student ID is not set.');
      return;
    }

    try {
      final response = await CallApi().getTapHistory(studid!);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('No data returned');
          return;
        }

        Iterable list = json.decode(response.body);
        data = list.map((model) => TapHistory.fromJson(model)).toList();

        print('Retrieved tap history: $data');
      } else {
        print(
            'Failed to load tap history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  static Future sendStatusNotification(TapHistory tapHistory) async {
    if (userFirstName == null) {
      await getUser();
    }

    String title = "LDCU";
    String body = "Hi $userFirstName, your status is now okay.";

    await showSimpleNotification(
      title: title,
      body: body,
      payload: tapHistory.toJson().toString(),
    );
  }
}
