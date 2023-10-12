import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/points.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';

import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/more_page_card.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  StatisticPageState createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  bool _loading = true;
  bool showAds = true;
  num _amountOfferedRides = 0;
  num _amountOfferedSeats = 0;
  num _amountDrivenPerson = 0;
  num _amountDrivenKM = 0;

  final BannerAd myBanner1 = BannerAd(
    adUnitId: (Platform.isAndroid)
        ? googleAdMobAndroidBannerId
        : googleAdMobIOSBannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    await getUserData();
    await getAmounts();
    String role = await MyPref.getRole();
    if (role == 'free') {
      showAds = true;
      await myBanner1.load();
    } else {
      showAds = false;
    }

    setState(() {
      _loading = false;
    });
  }

  getAmounts() async {
    _amountOfferedRides = 0;
    _amountOfferedSeats = 0;
    _amountDrivenPerson = 0;
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .where('createdById', isEqualTo: currentUserInformations.id)
        .get()
        .then((rides) {
      for (var ride in rides.docs) {
        print(ride.data());
        _amountOfferedRides++;
        _amountOfferedSeats += ride.get('offeredSeats');
        num difference = ride.get('offeredSeats') - ride.get('freeSeats');
        _amountDrivenPerson += difference;
        print(ride.get('distance'));
        _amountDrivenKM += ride.get('distance');
      }
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
              height: 130,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  AppBarBackArrowWidget(
                    textt: MyLocalization().myStatisticPageTitle.tr,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  showAds
                      ? Visibility(
                          visible: !kIsWeb,
                          child: SizedBox(
                            height: 60,
                            child: AdWidget(ad: myBanner1),
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      /*MorePageCards(
                        textt: MyLocalization().myStatisticPageLevelLable.tr,
                        url: 'assets/settings/level.png',
                        trailingText: currentUserInformations.level.toString(),
                        onPressed: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => const MyRideScreen(),
                          // ));
                        },
                      ),*/
                      MorePageCards(
                        textt: MyLocalization().myStatisticPagePointsLable.tr,
                        url: 'assets/settings/points.png',
                        trailingText: currentUserInformations.points.toString(),
                        onPressed: () {
                          var selected =
                              double.parse(_amountOfferedSeats.toString());
                          var offered =
                              double.parse(_amountOfferedRides.toString());
                          var drivenKm =
                              double.parse(_amountDrivenKM.toString());
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PointsScreen(
                              selected: selected,
                              offered: offered,
                              drivenKm: drivenKm,
                            ),
                          ));
                        },
                      ),
                      MorePageCards(
                        textt:
                            MyLocalization().myStatisticPageOfferedCarsLable.tr,
                        url: 'assets/settings/offeredcar.png',
                        trailingText: _amountOfferedRides.toString(),
                        onPressed: () {},
                      ),
                      MorePageCards(
                        textt: MyLocalization()
                            .myStatisticPageOfferedSeatsLable
                            .tr,
                        url: 'assets/settings/offeredseat.png',
                        trailingText: _amountOfferedSeats.toString(),
                        onPressed: () {},
                      ),
                      MorePageCards(
                        textt: MyLocalization().costPerKM.tr,
                        url: 'assets/settings/totalcost.png',
                        trailingText: '${currentUserInformations.costPerKM}\$',
                        onPressed: () {},
                      ),
                      MorePageCards(
                        textt: MyLocalization().myStatisticPageDrivenKMLable.tr,
                        url: 'assets/settings/drivenkm.png',
                        trailingText: _amountDrivenPerson.toString(),
                        onPressed: () {},
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
