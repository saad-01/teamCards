import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/Events/Widgets/appbar_back_arrow_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, required this.notif});
  final bool notif;

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<NotificationPage> {

  Future<void> _setData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifs', notifications);
  }

  @override
  void initState() {
    super.initState();
    notifications = widget.notif;
  }

  late bool notifications;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(
                  textt: MyLocalization().notification.tr,
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 1),
                  child: Card(
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            color: MyColors.kGreenColor, width: 0.3)),
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active, color: MyColors.kGreenColor,),
                      title: Row(
                        children: [
                          const Text(
                            '|\t\t',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200),
                          ),
                          Text(
                            MyLocalization().notification.tr,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: notifications,
                        onChanged: (value) async {
                          final _frb = FirebaseMessaging.instance;
                          notifications = value;
                          setState(() {});
                          if(!value) {
                            await _frb.deleteToken();
                            if(!kIsWeb) {
                              await _frb.unsubscribeFromTopic('notifs');
                            }
                            await FlutterLocalNotificationsPlugin().cancelAll();
                            await FirebaseFirestore.instance
                                .collection(FirebaseCollection().users)
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "fcmtoken": "",
                              "pushNotification": false,
                            });
                          } else {
                            var token = await _frb.getToken();
                            if(!kIsWeb) {
                              await _frb.subscribeToTopic('notifs');
                            }
                            await FirebaseFirestore.instance
                                .collection(FirebaseCollection().users)
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "fcmtoken": token,
                              "pushNotification": true,
                            });
                          }
                          await _setData();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
