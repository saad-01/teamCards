import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../More/Widgets/group_list_card_widget.dart';
import '../../More/Widgets/points_card_widget.dart';

class GroupMemberPage extends StatefulWidget {
  const GroupMemberPage({
    super.key,
    required this.groupId,
    required this.adminView,
    required this.memberId,
    required this.name,
    required this.level,
    required this.image,
  });
  final String groupId;
  final bool adminView;
  final String memberId;
  final String name;
  final String level;
  final String image;

  @override
  GroupMemberPageState createState() => GroupMemberPageState();
}

class GroupMemberPageState extends State<GroupMemberPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool _loading = true;
  bool isDrawerOpen = false;
  num _amountOfferedSeats = 0;
  num _amountOfferedRides = 0;
  num _amountDrivenPerson = 0;
  num _totalRides = 0;
  num _amountDrivenKM = 0;
  bool showAds = true;
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
    String role = await MyPref.getRole();
    if (role == 'free') {
      showAds = true;
      await myBanner1.load();
    } else {
      showAds = false;
    }
    await getUserData();
    await getAmounts();
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
        .where('createdById', isEqualTo: widget.memberId)
        .get()
        .then((rides) {
      for (var ride in rides.docs) {
        _amountOfferedRides++;
        _amountOfferedSeats += ride.get('offeredSeats');
        num difference = ride.get('offeredSeats') - ride.get('freeSeats');
        _amountDrivenPerson += difference;
        _amountDrivenKM += ride.get('distance');
      }
      if (_amountDrivenPerson < 0) {
        _amountDrivenPerson = 0;
      }
      _totalRides = rides.docs.length;
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
              height: 260,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarBackArrowWidget(
                  textt: MyLocalization().myGroups.tr,
                  pencileUrl: null,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 30, bottom: 10),
                  child: GroupListCard(
                    title: widget.name,
                    subtitle: "${MyLocalization().level.tr} ${widget.level}",
                    url: widget.image,
                  ),
                ),
                showAds
                    ? Visibility(
                        visible: !kIsWeb && !_loading,
                        child: SizedBox(
                          height: 60,
                          child: AdWidget(ad: myBanner1),
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 50.0, top: 10, bottom: 10),
                  child: Text(
                    MyLocalization().activities.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: PointScreenCard(
                            url: 'assets/settings/totalrides.png',
                            distance: _totalRides.toString(),
                            title: MyLocalization().totalRides.tr,
                            color: MyColors.kGreenColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: PointScreenCard(
                            url: 'assets/settings/seatoffered.png',
                            distance: _amountOfferedSeats.toString(),
                            title: MyLocalization().seatsOffered.tr,
                            color: MyColors.kGreenColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: PointScreenCard(
                            url: 'assets/settings/seatselected.png',
                            distance: _amountDrivenPerson.toString(),
                            title: MyLocalization().selectedSeats.tr,
                            color: const Color(0xff95C11F),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 30),
                          child: PointScreenCard(
                            url: 'assets/settings/kmdriven.png',
                            distance: _amountDrivenKM.toStringAsFixed(2),
                            title: MyLocalization().drivenKm.tr,
                            color: const Color(0xff00C897),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
