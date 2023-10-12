import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_page.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/settings_page.dart';
import 'package:nachhaltiges_fahren/pages/my_driverrides_page.dart';
import 'package:nachhaltiges_fahren/pages/my_guestrides_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../Home/Widgets/profile_card.dart';
import '../../basic_page.dart';
import '../Widgets/more_page_card.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  int selectIndex = 3;
  RxString role = 'free'.obs;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    role.value = await MyPref.getRole();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kGreenColor,
        body: ListView(
          children: [
            ProfileCard(
              name: currentUserInformations.name,
              description:
                  getCurrentUserLevelDescription(currentUserInformations.level),
              level: currentUserInformations.level.toString(),
              profilePhoto: currentUserInformations.image,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
              child: Column(
                children: [
                  MorePageCards(
                    textt: MyLocalization().home.tr,
                    url: 'assets/home/home.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomeScreen(idGetter: 0),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().events.tr,
                    url: 'assets/home/events.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomeScreen(idGetter: 1),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().myRides.tr,
                    url: 'assets/home/myrides.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyGuestRidesPage(),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().myTakenRides.tr,
                    url: 'assets/home/mytakenrides.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyRidesPage(),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().messages.tr,
                    url: 'assets/home/chaticon.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomeScreen(idGetter: 2),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().myGroups.tr,
                    url: 'assets/home/groupicon.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GroupsPage(),
                      ));
                    },
                  ),
                  MorePageCards(
                    textt: MyLocalization().removeAds.tr,
                    url: 'assets/home/diamond.png',
                    onPressed: () async {
                      //Get customer info and buy product and make user premium
                      final customerInfo = await Purchases.getCustomerInfo();

                      if (customerInfo.entitlements.active.isNotEmpty) {
                        //user has access to some entitlement
                        Fluttertoast.showToast(
                            msg: 'Already subscribed',
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: MyColors.kGreenColor);
                      } else {
                        if (Platform.isAndroid) {
                          CustomerInfo info = await Purchases.purchaseProduct(
                              Keys.playMonthlyPlan);
                          bool isMonthlyPlanActive =
                              info.activeSubscriptions.contains("remove_ads");
                          if (isMonthlyPlanActive) {
                            MyPref.saveUserRole('premium');
                          } else {
                            MyPref.saveUserRole('free');
                          }
                        } else if (Platform.isIOS) {
                          CustomerInfo info = await Purchases.purchaseProduct(
                              Keys.playMonthlyPlan);
                          bool isMonthlyPlanActive =
                              info.entitlements.active.isNotEmpty;
                          if (isMonthlyPlanActive) {
                            MyPref.saveUserRole('premium');
                          } else {
                            MyPref.saveUserRole('free');
                          }
                        }
                      }
                    },
                  ),
                  Obx(() =>MorePageCards(
                    textt: role.value,
                    url: 'assets/home/settings.png',
                    onPressed: () {},
                  ),),
                  
                  MorePageCards(
                    textt: MyLocalization().settings.tr,
                    url: 'assets/home/settings.png',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ));
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.only(right: 35, bottom: 35),
                    height: 70,
                    width: 70,
                    child: Image.asset(
                      'assets/home/more_icon.png',
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
