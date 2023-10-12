import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nachhaltiges_fahren/pages/Events/Screens/events_page.dart';
import 'package:nachhaltiges_fahren/pages/Home/pages/home_page.dart';
import 'package:nachhaltiges_fahren/pages/Messages/Screens/messages_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/more.dart';
import 'package:nachhaltiges_fahren/pages/ride_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../locale_notification_service.dart';
import '../routes/route_services.dart';
import '../assets/widgets/loading.dart';
import 'Events/Screens/event_details_page.dart';
import 'Home/Widgets/bottom_app_bar.dart';
import 'Messages/Screens/chat_details.dart';

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

class BasicPage extends StatelessWidget {
  final int idGetter;
  const BasicPage({this.idGetter = 0, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(
        idGetter: idGetter,
      ),
      title: appName,
      onGenerateRoute: RouteServices.generateRoute,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int idGetter;
  const HomeScreen({required this.idGetter, super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

var idPage = 0;
int _page = 0;

class HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String deviceToken = " ";

  @override
  initState() {
    super.initState();
    _getData();

    currentIndex = widget.idGetter;
  }

  _getData() async {
    await getUserData();
    requestPermission();

    loadFCM();

    getToken();
    if (!kIsWeb) {
      initDynamicLinks();
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      if (dynamicLinkData.link.queryParameters.containsKey('groupid')) {
        Navigator.pushNamed(context, '/addMember', arguments: {
          'groupid': dynamicLinkData.link.queryParameters['groupid']
        });
      } else {
        Navigator.pushNamed(context, '/addMember',
            arguments: {'groupid': '123'});
      }
    }).onError((error) {
      if (kDebugMode) {
        print('onLink error');
      }
      if (kDebugMode) {
        print(error.message);
      }
    });
  }

  void getToken() async {
    final firebaseMessaging = FirebaseMessaging.instance;

    final enabled = await SharedPreferences.getInstance();
    final notif = enabled.getBool('notifs') ?? true;

    await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails()
        .then((value) {
      if (value != null && value.didNotificationLaunchApp) {
        String? payload = value.notificationResponse!.payload;
        String data = payload.toString();
        List list = data.split(',');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailsPage(
              eventLocation: list[0],
              userLastOnline: list[1],
              createdById: list[2],
              location: list[3],
              groupName: list[4],
              description: list[5],
              rideId: list[6],
              date: list[7],
              event: list[8],
              createdByName: list[9],
              image: list[10],
              time: list[11],
              eventId: list[12],
              flexibleTime: {
                "before": int.parse(list[14].split(' ')[0]),
                "after": int.parse(list[14].split(' ')[1]),
              },
              flexibleTimeValue: list[13],
            ),
          ),
        );
      }
    });

    if (notif) {
      await FirebaseMessaging.instance.getToken().then((token) {
        if (kDebugMode) {
          print("Token: $token");
        }
        setState(() {
          deviceToken = token!;

          FirebaseFirestore.instance
              .collection(FirebaseCollection().users)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'fcmtoken': deviceToken,
          }).then((value) {
            if (kDebugMode) {
              print("Usertoken Updated");
            }
          }).catchError((error) {
            if (kDebugMode) {
              print("Failed to update usertoken: $error");
            }
          });
        });
        firebaseMessaging.subscribeToTopic('notifs');

        FirebaseMessaging.onMessage.listen((message) async {
          print(message.data);
          if (message.notification != null) {
            try {
              NotificationService().showNotification(message);
              return;
            } catch (_) {}
          }
        });
        FirebaseMessaging.onMessageOpenedApp.listen((event) {
          if (event.data['info'] != null && event.data['info'] != {}) {
            if (event.data['info']['type'] == 'message') {
              var data = event.data['info'];
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(
                          otherName: data['otherName'],
                          otherUserId: data['otherUserId'],
                          otherImage: data['otherImage'],
                          lastOnline: '',
                          chatRoomId: data['chatRoomId'],
                          isSenderMe: data['isSenderMe'],
                          drivenKm: '',
                        )),
              );
            } else if (event.data['info']['type'] == 'event') {
              var data = event.data['info'];
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EventDetailsPage(
                          createdById: data['createdById'],
                          eventImage: data['eventImage'],
                          image: data['groupImage'],
                          eventId: data['eventId'],
                          event: data['eventName'],
                          groupId: data['groupId'],
                          group: data['groupName'],
                          location: data['location'],
                          description: data['description'],
                          date: data['date'],
                          time: data['time'],
                        )),
              );
            }
          }
          return print(event.data);
        });
        FirebaseMessaging.onBackgroundMessage((message) {
          return _firebaseMessagingBackgroundHandler(message);
        });
      });
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  //final _advancedDrawerController = AdvancedDrawerController();
  int currentIndex = 0;

  final _pages = const [
    HomePage(),
    EventsPage(),
    MessagePage(),
    Scaffold(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Loading());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _pages[currentIndex],
      bottomNavigationBar: CustomBottomAppBar(
        selectIndex: currentIndex,
        onChange: (value) {
          if (value == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const More()));
          } else {
            setState(() {
              currentIndex = value;
            });
          }
        },
      ),
    );
    // return AdvancedDrawer(
    //   backdropColor: Colors.blueGrey,
    //   controller: _advancedDrawerController,
    //   animationCurve: Curves.easeInOut,
    //   animationDuration: const Duration(milliseconds: 300),
    //   animateChildDecoration: true,
    //   rtlOpening: false,
    //   // openScale: 1.0,
    //   disabledGestures: false,
    //   childDecoration: const BoxDecoration(
    //     // NOTICE: Uncomment if you want to add shadow behind the page.
    //     // Keep in mind that it may cause animation jerks.
    //     boxShadow: <BoxShadow>[
    //       BoxShadow(
    //         color: Colors.black12,
    //         blurRadius: 0.0,
    //       ),
    //     ],
    //     borderRadius: BorderRadius.all(Radius.circular(16)),
    //   ),
    //   drawer: navigationDrawer(),
    //   child:
    // );
  }

  // SafeArea navigationDrawer() {
  //   return SafeArea(
  //     child: ListTileTheme(
  //       textColor: Colors.white,
  //       iconColor: Colors.white,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.max,
  //         children: [
  //           Container(
  //             width: 128.0,
  //             height: 128.0,
  //             margin: const EdgeInsets.only(
  //               top: 24.0,
  //               bottom: 5.0,
  //             ),
  //             clipBehavior: Clip.antiAlias,
  //             decoration: const BoxDecoration(
  //               color: Colors.black26,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Image.network(
  //               currentUserInformations.image,
  //             ),
  //           ),
  //           Text(
  //             currentUserInformations.name,
  //             style: GoogleFonts.racingSansOne(
  //               fontSize: 23,
  //               color: Colors.white70,
  //               letterSpacing: 1.8,
  //             ),
  //           ),
  //           Text(
  //             "Level ${currentUserInformations.level}",
  //             style: GoogleFonts.racingSansOne(
  //                 fontSize: 17,
  //                 color: Colors.white70,
  //                 letterSpacing: 1.8,
  //                 fontWeight: FontWeight.normal),
  //           ),
  //           const SizedBox(
  //             height: 60,
  //           ),
  //           for (var menuEntry in drawerItems) menuListTile(menuEntry.id),
  //           const Spacer(),
  //           DefaultTextStyle(
  //             style: const TextStyle(
  //               fontSize: 12,
  //               color: Colors.white54,
  //             ),
  //             child: Container(
  //               margin: const EdgeInsets.symmetric(
  //                 vertical: 16.0,
  //               ),
  //               child: GestureDetector(
  //                   onTap: (() {
  //                     launchUrl(Uri.parse("https://kevindroll.de"));
  //                   }),
  //                   child: const Text('Created by Kevin Droll')),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // ListTile menuListTile(int id) {
  //   return ListTile(
  //     onTap: () {
  //       setState(() {
  //         _page = drawerItems[id].id;
  //         _advancedDrawerController.hideDrawer();
  //       });
  //     },
  //     leading: drawerItems[id].icon,
  //     title: Text(drawerItems[id].title),
  //   );
  // }
  //
  // void _handleMenuButtonPressed() {
  //   // NOTICE: Manage Advanced Drawer state through the Controller.
  //   // _advancedDrawerController.value = AdvancedDrawerValue.visible();
  //   _advancedDrawerController.showDrawer();
  // }
}
