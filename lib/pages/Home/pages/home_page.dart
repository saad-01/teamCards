import 'dart:io' if (dart.library.js) 'dart:html';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/Events/Screens/events_add_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_add_member_by_link_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_select_page.dart';
import 'package:nachhaltiges_fahren/pages/Home/Widgets/event_card.dart';
import 'package:nachhaltiges_fahren/pages/Home/Widgets/ride_card.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Screens/event_details_page.dart';
import '../../ride_details_page.dart';
import '../Widgets/appbar_widget.dart';
import '../Widgets/heading.dart';
import '../Widgets/home_page_bottons.dart';
import '../Widgets/profile_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _loading = true;
  bool showAds = true;

  late final BannerAd? myBanner1;

  late final BannerAd? myBanner2;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    //checking if user has active subscription than make it premium
    String email = await MyPref.getEmail();
    await Purchases.logIn(email);
    final customerInfo = await Purchases.getCustomerInfo();
    bool isMonthlyPlanActive =
        customerInfo.entitlements.active.isNotEmpty;
    if (isMonthlyPlanActive) {
      MyPref.saveUserRole('premium');
    } else {
      MyPref.saveUserRole('free');
    }
    String role = await MyPref.getRole();
    if (role == 'free') {
      showAds = true;
      if (!kIsWeb) {
        myBanner1 = BannerAd(
          adUnitId: (Platform.isAndroid)
              ? googleAdMobAndroidBannerId
              : googleAdMobIOSBannerId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: const BannerAdListener(),
        );
        myBanner2 = BannerAd(
          adUnitId: (Platform.isAndroid)
              ? googleAdMobAndroidBannerId
              : googleAdMobIOSBannerId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: const BannerAdListener(),
        );
        myBanner1!.load();
        myBanner2!.load();
      }
    } else {
      showAds = false;
    }

    await getUserData();
    await getReview();
    setState(() {
      _loading = false;
    });
  }

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;
  int selectIndex = 0;

  Widget noRide() => Column(
        children: [
          const SizedBox(height: 15),
          Image.asset(
            'assets/home/cycle.png',
            width: 100,
            height: 90,
            fit: BoxFit.contain,
          ),
          Text(
            MyLocalization().myRidesPageNoRidesText.tr,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            MyLocalization().addRideText.tr,
            style: const TextStyle(color: MyColors.kGreenColor),
          ),
          const SizedBox(height: 15),
        ],
      );
  Widget noEvent() => Column(
        children: [
          const SizedBox(height: 15),
          Image.asset(
            'assets/event/eventicon.PNG',
            width: 100,
            height: 90,
            fit: BoxFit.contain,
          ),
          Text(
            MyLocalization().noEventText.tr,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EventAddPage(),
                ));
              },
              child: Text(
                MyLocalization().addEventText.tr,
                style: const TextStyle(color: MyColors.kGreenColor),
              )),
          const SizedBox(height: 15),
        ],
      );
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kGreenColor,
        body: Stack(children: [
          Flex(
            direction: Axis.vertical,
            children: [
              Flexible(
                flex: 5,
                child: Container(
                  color: MyColors.kGreenColor,
                ),
              ),
              Flexible(
                flex: 15,
                child: Container(
                  decoration: const BoxDecoration(
                      color: MyColors.kBackGroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppBarWidget(
                  textt: MyLocalization().home.tr,
                  imageAddress: 'assets/home/languageGlobe.png',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LanguageSelectPage(),
                    ));
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  child: ProfileCard(
                    name: currentUserInformations.name,
                    profilePhoto: currentUserInformations.image,
                    description: getCurrentUserLevelDescription(
                        currentUserInformations.level),
                    level: currentUserInformations.level.toString(),
                  ),
                ),
                Heading(heading: MyLocalization().availableEvents.tr),
                const SizedBox(height: 5),

                // Events
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(FirebaseCollection().events)
                      .where('groupId',
                          whereIn: currentUserInformations.memberGroups)
                      .where('time', isGreaterThanOrEqualTo: DateTime.now())
                      .orderBy('time', descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.hasData && snapshot.data!.docs.isEmpty ||
                        snapshot.hasError) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: MyColors.kWhiteColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: noEvent(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Loading(small: true);
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15)
                          .copyWith(top: 10, bottom: 20),
                      height: height / 5,
                      child: PageView(
                        children: snapshot.data!.docs.map(
                          (document) {
                            String createdById = document['createdById'];
                            String eventId = document.id;
                            String title = document['title'];
                            Timestamp time = document['time'] ?? "";
                            DateTime date = time.toDate();
                            String description = document['description'] ?? "";
                            GeoPoint location = document['location'];
                            String groupId = document['groupId'] ?? "";
                            String image = '';
                            try {
                              image = document.get('image');
                            } catch (_) {}
                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection(FirebaseCollection().groups)
                                  .doc(groupId)
                                  .get(),
                              builder: ((context, groupShot) {
                                if (!groupShot.hasData) {
                                  return const SizedBox();
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsPage(
                                          createdById: createdById,
                                          groupId: groupId,
                                          eventId: eventId,
                                          date: formatterDDMMYYYY
                                              .format(date)
                                              .toString(),
                                          description: description,
                                          event: title,
                                          group: groupShot.data!['name'],
                                          image: groupShot.data!['image'] ?? "",
                                          location: location,
                                          time: formatterHHMM
                                              .format(date)
                                              .toString(),
                                          eventImage: image,
                                        ),
                                      ),
                                    );
                                  },
                                  child: EventCardHome(
                                    image: groupShot.data!['image'] ?? "",
                                    location: location,
                                    date: formatterDDMMYYYY
                                        .format(date)
                                        .toString(),
                                    time: formatterHHMM.format(date).toString(),
                                    title: groupShot.data!['name'],
                                    subtitle: title,
                                  ),
                                );
                              }),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                ),
                showAds
                    ?
                    // Ad Banner
                    Visibility(
                        visible: !kIsWeb,
                        child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: AdWidget(ad: myBanner1!)),
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 15,
                ),
                Heading(heading: MyLocalization().myFutureRides.tr),
                const SizedBox(height: 10),
                // Rides
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: MyColors.kWhiteColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(FirebaseCollection().rides)
                        .where('createdById',
                            isEqualTo: currentUserInformations.id)
                        .where('departureTime',
                            isGreaterThanOrEqualTo: DateTime.now())
                        .orderBy('departureTime', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loading(small: true);
                      } else if (!snapshot.hasData ||
                          snapshot.hasData && snapshot.data!.docs.isEmpty) {
                        return noRide();
                      }

                      return SizedBox(
                        height: height > 800 ? height / 4 : height * 0.3,
                        child: PageView(
                          scrollDirection: Axis.horizontal,
                          children: snapshot.data!.docs.map(
                            (document) {
                              String rideId = document.id;
                              String eventId = document['eventId'];
                              String createdById = document['createdById'];
                              num freeSeats = document['freeSeats'];
                              num offeredSeats = document['offeredSeats'];
                              String description = document['description'];
                              num distance = document['distance'];
                              DateTime departureTime =
                                  document['departureTime'].toDate();
                              GeoPoint location = document['location'];
                              List passenger = document['passenger'];
                              bool flexibleTimeValue =
                                  document['isFlexibleTime'];
                              Map flexibleTime = {};
                              try {
                                flexibleTime = document['flexibleTime'];
                              } catch (_) {}
                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection(FirebaseCollection().events)
                                      .doc(eventId)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          eventDoc) {
                                    if (!eventDoc.hasData) {
                                      return const Loading();
                                    }
                                    String groupId = eventDoc.data!['groupId'];

                                    return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection(
                                              FirebaseCollection().groups)
                                          .doc(groupId)
                                          .get(),
                                      builder: (context, groupDoc) {
                                        if (!groupDoc.hasData) {
                                          return const SizedBox();
                                        }
                                        String image = '';
                                        try {
                                          image = eventDoc.data!.get('image');
                                        } catch (_) {}
                                        return HomeRideCard(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RideDetailsPage(
                                                  eventLocation: eventDoc
                                                      .data!['location'],
                                                  userLastOnline:
                                                      formatterDDMMYYYHHMM
                                                          .format(
                                                              currentUserInformations
                                                                  .lastLogin
                                                                  .toDate())
                                                          .toString(),
                                                  createdById: createdById,
                                                  location: location,
                                                  groupName: groupDoc.data!
                                                      .get('name'),
                                                  description: description,
                                                  rideId: rideId,
                                                  date: formatterDDMMYYYY
                                                      .format(departureTime)
                                                      .toString(),
                                                  event: eventDoc.data!
                                                      .get('title'),
                                                  createdByName:
                                                      currentUserInformations
                                                          .name,
                                                  image: currentUserInformations
                                                      .image,
                                                  time: formatterHHMM
                                                      .format(departureTime)
                                                      .toString(),
                                                  eventId: eventId,
                                                  flexibleTime: flexibleTime,
                                                  flexibleTimeValue:
                                                      flexibleTimeValue,
                                                ),
                                              ),
                                            );
                                          },
                                          distance: distance,
                                          location: location,
                                          description: description,
                                          freeSeats: freeSeats,
                                          offeredSeats: offeredSeats,
                                          eventImage: image,
                                          groupTitle:
                                              groupDoc.data!.get('name'),
                                          eventTitle:
                                              eventDoc.data!.get('title'),
                                          eventDate: formatterDDMMYYYHHMM
                                              .format(departureTime)
                                              .toString(),
                                          passengers: passenger,
                                        );
                                      },
                                    );
                                  });
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ),
                ),
                //button
                const SizedBox(
                  height: 20,
                ),
                showAds
                    ? Visibility(
                        visible: !kIsWeb,
                        child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: AdWidget(ad: myBanner2!)),
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  height: 100,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomePageButton(
                        textt: MyLocalization().addGroup.tr,
                        icon: Icons.group_add_outlined,
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GroupsPage())),
                      ),
                      HomePageButton(
                        textt: MyLocalization().addEvent.tr,
                        icon: Icons.post_add_sharp,
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EventAddPage())),
                      ),
                      HomePageButton(
                        textt: MyLocalization().invite.tr,
                        icon: Icons.send,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const GroupSelectPage(),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget highlightShortcuts(
    IconData icon,
    String title,
    Function() onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: 2,
                      color: MyColors.subheadingColor,
                    ),
                  ),
                  child: Icon(
                    size: 22,
                    icon,
                    color: MyColors.subheadingColor,
                  ),
                ),
                AutoSizeText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  title,
                  style: TextStyle(color: MyColors.subheadingColor),
                ),
              ],
            )),
      ),
    );
  }
}
