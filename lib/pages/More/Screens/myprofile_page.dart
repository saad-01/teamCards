import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/pages/login_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/myprofile_edit_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/statistic_page.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';

import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/message_profile_card.dart';
import '../Widgets/more_page_card.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  MyProfilePageState createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  AppBarBackArrowWidget(
                    textt: MyLocalization().profile.tr,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ProfileCardForMessage(
                      url: currentUserInformations.image,
                      title: currentUserInformations.name,
                      subtitle: getCurrentUserLevelDescription(
                          currentUserInformations.level),
                      thirdtitle:
                          '${MyLocalization().level.tr} ${currentUserInformations.level}',
                      disctanceUrl: 'assets/home/level1.png',
                      editable: false,
                    ),
                  ),
                  Column(
                    children: [
                      MorePageCards(
                        textt: MyLocalization().statistics.tr,
                        url: 'assets/settings/statistic.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const StatisticPage(),
                          ));
                        },
                      ),
                      MorePageCards(
                        textt: MyLocalization().editProfile.tr,
                        url: 'assets/settings/editprofile.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyProfileEditPage(),
                          ));
                        },
                      ),
                      MorePageCards(
                        textt: MyLocalization().changeEmail.tr,
                        url: 'assets/settings/changeemail.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ChangeEmailPage(),
                          ));
                        },
                      ),
                      MorePageCards(
                        textt: MyLocalization().changePassword.tr,
                        url: 'assets/settings/changepwd.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20),
                        child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shadowColor: MyColors.kGreenColor,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.red,
                                            size: 32,
                                          ),
                                          title: Text(
                                            MyLocalization().deleteUser.tr,
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Text(
                                            MyLocalization().deleteUserText.tr,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Container(
                                          margin: const EdgeInsets.all(10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await FirebaseFirestore.instance
                                                  .doc(
                                                      'users/${currentUserInformations.id}')
                                                  .delete();
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.delete()
                                                  .then((value) {
                                                Navigator.pushAndRemoveUntil(
                                                    context, MaterialPageRoute(
                                                        builder: (context) {
                                                  return const LoginPage();
                                                }), (route) => false);
                                              });
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(10),
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: MyColors.kGreenColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.kWhiteColor,
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: MyColors.kBlackColor,
                                        width: .2)),
                                foregroundColor: Colors.red.shade700,
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                                minimumSize: const Size(double.infinity, 52)),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade700,
                            ),
                            label: Text(MyLocalization().deleteUser.tr)),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
