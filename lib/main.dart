// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:pushtrial/push_notifications.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'firebase_options.dart';
// import '../models/user.dart';
// import 'auth/login.dart';
// import 'screens/loading.dart';
// import 'screens/home.dart';
// import 'screens/notifications.dart';

// final navigatorKey = GlobalKey<NavigatorState>();

// // function to lisen to background changes
// Future _firebaseBackgroundMessage(RemoteMessage message) async {
//   if (message.notification != null) {
//     print("Some notification Received");
//   }
// }

// // to handle notification on foreground on web platform
// void showNotification({required String title, required String body}) {
//   showDialog(
//     context: navigatorKey.currentContext!,
//     builder: (context) => AlertDialog(
//       title: Text(title),
//       content: Text(body),
//       actions: [
//         TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text("Ok"))
//       ],
//     ),
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // on background notification tapped
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     if (message.notification != null) {
//       print("Background Notification Tapped");
//       navigatorKey.currentState!
//           .pushNamed("/notifications", arguments: message);
//     }
//   });

//   PushNotifications.init();
//   // only initialize if platform is not web
//   if (!kIsWeb) {
//     PushNotifications.localNotiInit();
//   }
//   // Listen to background notifications
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

//   // to handle foreground notifications
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     String payloadData = jsonEncode(message.data);
//     print("Got a message in foreground");
//     if (message.notification != null) {
//       if (kIsWeb) {
//         showNotification(
//             title: message.notification!.title!,
//             body: message.notification!.body!);
//       } else {
//         PushNotifications.showSimpleNotification(
//             title: message.notification!.title!,
//             body: message.notification!.body!,
//             payload: payloadData);
//       }
//     }
//   });

//   // for handling in terminated state
//   final RemoteMessage? message =
//       await FirebaseMessaging.instance.getInitialMessage();

//   if (message != null) {
//     print("Launched from terminated state");
//     Future.delayed(Duration(seconds: 1), () {
//       navigatorKey.currentState!
//           .pushNamed("/notifications", arguments: message);
//     });
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Student Portal',
//       theme: ThemeData(
//         textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
//       ),
//       initialRoute: '/loading',
//       routes: {
//         '/loading': (context) => LoadingScreen(),
//         '/login': (context) => Login(),
//         '/home': (context) {
//           final user = ModalRoute.of(context)!.settings.arguments as User?;
//           if (user == null) {
//             return Login();
//           }
//           return HomeScreen(user: user);
//         },
//         '/notifications': (context) => NotificationsScreen(),
//       },
//     );
//   }
// }

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/push_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import '../models/user.dart';
import 'auth/login.dart';
import 'screens/loading.dart';
import 'screens/home.dart';
import 'screens/notifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Background message handler
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  if (message.notification != null) {
    print("Background Notification Received: ${message.notification!.title}");

    // Pass the message to the PushNotifications class for processing
    await PushNotifications.showSimpleNotification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      payload: jsonEncode(message.data),
    );
  }
}

// Show notification in a dialog for web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"))
      ],
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Listen for when the app is opened from a background notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!
          .pushNamed("/notifications", arguments: message);
    }
  });

  PushNotifications.init();

  // Initialize local notifications if the platform is not web
  if (!kIsWeb) {
    await PushNotifications.localNotiInit();
  }

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Foreground Notification Received");

    if (message.notification != null) {
      if (kIsWeb) {
        showNotification(
            title: message.notification!.title!,
            body: message.notification!.body!);
      } else {
        PushNotifications.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    }
  });

  // Handle notifications when the app is launched from a terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!
          .pushNamed("/notifications", arguments: message);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Student Portal',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingScreen(),
        '/login': (context) => Login(),
        '/home': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User?;
          if (user == null) {
            return Login();
          }
          return HomeScreen(user: user);
        },
        '/notifications': (context) => NotificationsScreen(),
      },
    );
  }
}
