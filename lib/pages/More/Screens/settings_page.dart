import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/development_ideas_page.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/feedback_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/help_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/myprofile_page.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import 'package:nachhaltiges_fahren/pages/login_page.dart';
import 'package:nachhaltiges_fahren/pages/notification_page.dart';
import 'package:nachhaltiges_fahren/pages/release_notes_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/message_profile_card.dart';
import '../Widgets/more_page_card.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool _loading = true;
  bool isDrawerOpen = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    await getUserData();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
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
                    textt: MyLocalization().settings.tr,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyProfilePage())),
                      child: ProfileCardForMessage(
                        url: currentUserInformations.image,
                        title: currentUserInformations.name,
                        subtitle: getCurrentUserLevelDescription(
                            currentUserInformations.level),
                        thirdtitle:
                            /*'${MyLocalization().level.tr} ${currentUserInformations.level}'*/ "",
                        disctanceUrl: 'assets/home/level1.png',
                        editable: false,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      MorePageCards(
                        textt: MyLocalization().notification.tr,
                        url: 'assets/settings/notification.png',
                        onPressed: () async {
                          await SharedPreferences.getInstance().then((value) {
                            bool notifs = value.getBool('notifs') ?? true;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => NotificationPage(
                                          notif: notifs,
                                        )));
                          });
                        },
                      ),
                      MorePageCards(
                        textt: MyLocalization().language.tr,
                        url: 'assets/settings/language.png',
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LanguageSelectPage())),
                      ),
                      MorePageCards(
                        textt: MyLocalization().developmentIdeas.tr,
                        url: 'assets/settings/development.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const DevelopmentIdeasPage(),
                          ));
                        },
                      ),
                      MorePageCards(
                        textt: MyLocalization().releaseNotes.tr,
                        url: 'assets/settings/release.png',
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReleaseNotesPage())),
                      ),
                      MorePageCards(
                        textt: MyLocalization().help.tr,
                        url: 'assets/settings/helpicon.png',
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HelpPage())),
                      ),
                      MorePageCards(
                        textt: MyLocalization().feedback.tr,
                        url: 'assets/settings/feedback.png',
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FeedbackPage())),
                      ),
                      MorePageCards(
                        textt: MyLocalization().review.tr,
                        url: 'assets/settings/review.png',
                        onPressed: () async {
                          if (kIsWeb) {
                            String url =
                                'https://play.google.com/store/apps/details?id=de.kevindroll.nachhaltigesfahren';
                            if (await canLaunchUrlString(url)) {
                              launchUrlString(url);
                            }
                          } else {
                            final InAppReview inAppReview =
                                InAppReview.instance;

                            inAppReview.openStoreListing(
                              appStoreId: appleAppStorId,
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10),
                        child: ElevatedButton(
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
                                            Icons.logout_rounded,
                                            color: MyColors.kGreenColor,
                                            size: 32,
                                          ),
                                          title: Text(
                                            MyLocalization().logOut.tr,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Text(
                                            MyLocalization().logOutText.tr,
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
                                              //clearing role and email stored
                                              SharedPreferences
                                                  sharedPreferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              MyPref.saveUserRole('');
                                              MyPref.saveUserEmail('');
                                              await FirebaseAuth.instance
                                                  .signOut()
                                                  .then((value) {
                                                Navigator.pushAndRemoveUntil(
                                                    context, MaterialPageRoute(
                                                        builder: (context) {
                                                  return const LoginPage();
                                                }), (route) => false);
                                              });
                                            },
                                            child: Text(
                                              MyLocalization().logOut.tr,
                                              style: const TextStyle(
                                                  color: MyColors.kGreenColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(10),
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Text(
                                              MyLocalization().cancel.tr,
                                              style: const TextStyle(
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
                                backgroundColor: MyColors.kGreenColor,
                                foregroundColor: MyColors.kWhiteColor,
                                textStyle: const TextStyle(fontSize: 18),
                                minimumSize: const Size(double.infinity, 52)),
                            child: Text(MyLocalization().logOut.tr)),
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
  // @override
  // Widget build(BuildContext context) {
  //   if (_loading) {
  //     return const Loading();
  //   }
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         const SizedBox(
  //           height: 30,
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 30),
  //           child: Column(
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => const MyProfilePage()),
  //                   );
  //                 },
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Stack(
  //                       children: [
  //                         CircleAvatar(
  //                           backgroundImage: NetworkImage(
  //                             currentUserInformations.image,
  //                           ),
  //                           backgroundColor: Colors.transparent,
  //                           radius: 45,
  //                         ),
  //                         const SizedBox(
  //                           width: 90,
  //                           height: 90,
  //                           child: CircularProgressIndicator(
  //                             color: Colors.transparent,
  //                             strokeWidth: 7,
  //                             value: 0,
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 90,
  //                           height: 90,
  //                           child: CircularProgressIndicator(
  //                             strokeWidth: 7,
  //                             color: MyColors.primaryColor,
  //                             value: currentUserInformations.points /
  //                                 levelUpValue,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(
  //                       width: 22,
  //                     ),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             currentUserInformations.name,
  //                             style: GoogleFonts.quicksand(
  //                               fontSize: 20,
  //                               color: Color(MyColors.heading),
  //                               letterSpacing: 1,
  //                             ),
  //                           ),
  //                           Text(
  //                             "Level ${currentUserInformations.level}",
  //                             style: GoogleFonts.racingSansOne(
  //                               fontSize: 19,
  //                               color: MyColors.subheadingColor,
  //                               letterSpacing: 1,
  //                             ),
  //                           ),
  //                           Text(
  //                             getCurrentUserLevelDescription(
  //                                 currentUserInformations.level),
  //                             style: GoogleFonts.racingSansOne(
  //                               fontSize: 13,
  //                               color: MyColors.subheadingColor,
  //                               letterSpacing: 1,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 30,
  //               ),
  //               Card(
  //                 elevation: 10,
  //                 child: Column(
  //                   children: [
  //                     Visibility(
  //                       visible: currentUserInformations.roleAdmin,
  //                       child: SettingsTile(
  //                         icon: Icons.new_label,
  //                         title: "Admin",
  //                         onTap: (() {
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => const AdminPage()));
  //                         }),
  //                       ),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.person,
  //                       title: MyLocalization().settingsPageItemUser.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     const MyProfilePage()));
  //                       }),
  //                     ),
  //                     /*
  //                     SettingsTile(
  //                       icon: Icons.groups,
  //                       title: MyLocalization().settingsPageItemGroups.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) =>
  //                                   const GroupSettingsPage()),
  //                         );
  //                       }),
  //                     ),*/
  //
  //                     SettingsTile(
  //                       icon: Icons.notifications,
  //                       title:
  //                           MyLocalization().settingsPageItemNotification.tr,
  //                       enabled: false,
  //                       nearAvailable: true,
  //                       onTap: (() {}),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.language,
  //                       title: MyLocalization().settingsPageItemLanguage.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) =>
  //                                   const LanguageChangePage()),
  //                         );
  //                       }),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.lightbulb,
  //                       title: MyLocalization()
  //                           .settingsPageItemDevelopmentIdeas
  //                           .tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     const DevelopmentIdeasPage()));
  //                       }),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.new_label,
  //                       title:
  //                           MyLocalization().settingsPageItemReleasNotes.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     const ReleaseNotesPage()));
  //                       }),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.help,
  //                       title: MyLocalization().settingsPageItemHelp.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => const HelpPage()),
  //                         );
  //                       }),
  //                     ),
  //                     Visibility(
  //                       visible: !kIsWeb,
  //                       child: Column(
  //                         children: [
  //                           ListTile(
  //                             leading: Icon(
  //                               Icons.feedback,
  //                               color: MyColors.primaryColor,
  //                             ),
  //                             title: Text(MyLocalization()
  //                                 .settingsPageItemFeedback
  //                                 .tr),
  //                             textColor: MyColors.primaryColor,
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) =>
  //                                         const FeedbackPage()),
  //                               );
  //                             },
  //                           ),
  //                           const Divider(thickness: 1),
  //                         ],
  //                       ),
  //                     ),
  //                     Visibility(
  //                       visible: !kIsWeb,
  //                       child: SettingsTile(
  //                         icon: Icons.reviews,
  //                         title: MyLocalization().settingsPageItemReview.tr,
  //                         onTap: (() async {
  //                           final InAppReview inAppReview =
  //                               InAppReview.instance;
  //
  //                           inAppReview.openStoreListing(
  //                             appStoreId: appleAppStorId,
  //                           );
  //                         }),
  //                       ),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.info,
  //                       title:
  //                           MyLocalization().settingsPageItemIntroduction.tr,
  //                       onTap: (() {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) =>
  //                                   const IntroductionPage()),
  //                         );
  //                       }),
  //                     ),
  //                     SettingsTile(
  //                       icon: Icons.logout,
  //                       title: MyLocalization().settingsPageItemLogout.tr,
  //                       dividerOnBottom: false,
  //                       onTap: (() {
  //                         showDialog(
  //                             context: context,
  //                             builder: (context) {
  //                               return AlertDialog(
  //                                 title: Text(MyLocalization()
  //                                     .settingsPageItemLogout
  //                                     .tr),
  //                                 content: Text(MyLocalization()
  //                                     .settingsPageDialogLogoutQuestion
  //                                     .tr),
  //                                 actions: <Widget>[
  //                                   TextButton(
  //                                       onPressed: () {
  //                                         FirebaseFirestore.instance
  //                                             .collection(
  //                                                 FirebaseCollection().users)
  //                                             .doc(currentUserInformations.id)
  //                                             .update({'fcmtoken': ""})
  //                                             .whenComplete(() async {
  //                                               final prefs =
  //                                                   await SharedPreferences
  //                                                       .getInstance();
  //                                               await prefs.clear();
  //                                             })
  //                                             .whenComplete(() async =>
  //                                                 await FirebaseAuth.instance
  //                                                     .signOut())
  //                                             .whenComplete(() {
  //                                               Navigator.push(
  //                                                 context,
  //                                                 MaterialPageRoute(
  //                                                   builder: (context) =>
  //                                                       const LoginPage(),
  //                                                 ),
  //                                               );
  //                                             });
  //                                       },
  //                                       child: Text(MyLocalization()
  //                                           .settingsPageDialogLogoutAcceptButton
  //                                           .tr)),
  //                                   TextButton(
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: Text(MyLocalization()
  //                                         .settingsPageDialogLogoutCancelButton
  //                                         .tr),
  //                                   )
  //                                 ],
  //                               );
  //                             });
  //                       }),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 50,
  //         ),
  //         DefaultTextStyle(
  //           style: const TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey,
  //           ),
  //           child: Container(
  //             margin: const EdgeInsets.symmetric(
  //               vertical: 16.0,
  //             ),
  //             child:
  //                 Text("${MyLocalization().settingsPageVersion.tr} $version"),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;
  final bool dividerOnBottom;
  final bool enabled;
  final bool nearAvailable;
  const SettingsTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.dividerOnBottom = true,
    this.enabled = true,
    this.nearAvailable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          enabled: enabled,
          leading: Icon(
            icon,
            color: MyColors.primaryColor,
          ),
          title: AutoSizeText(title, maxLines: 1),
          textColor: MyColors.primaryColor,
          onTap: onTap,
          subtitle: Visibility(
            visible: nearAvailable,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Chip(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: MyColors.secondColor,
                  label: Text(
                    MyLocalization().settingsPageBadgeSoonAvailable.tr,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          trailing: Visibility(
              visible: enabled, child: const Icon(Icons.arrow_forward_ios)),
        ),
        Visibility(visible: dividerOnBottom, child: const Divider(thickness: 1))
      ],
    );
  }
}
