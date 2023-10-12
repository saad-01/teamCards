import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/Events/Widgets/event_detail_card.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import 'package:nachhaltiges_fahren/pages/Events/Screens/event_details_page.dart';
import 'package:nachhaltiges_fahren/pages/Events/Screens/events_add_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Home/Widgets/appbar_widget.dart';
import '../Widgets/filter_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isCurrentUserGroupAdmin = false;
  bool isDrawerOpen = false;
  bool _loading = true;
  bool showAds = true;
  late final BannerAd myBanner1;
  Stream<QuerySnapshot<Map<String, dynamic>>> _getMyEvents = FirebaseFirestore
      .instance
      .collection(FirebaseCollection().events)
      .where('groupId', whereIn: currentUserInformations.memberGroups)
      .where('time', isGreaterThanOrEqualTo: DateTime.now())
      .orderBy('time', descending: false)
      .snapshots();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    String role = await MyPref.getRole();
    if (!kIsWeb) {
      if (role == 'free') {
        showAds = true;
        myBanner1 = BannerAd(
          adUnitId: (Platform.isAndroid)
              ? googleAdMobAndroidBannerId
              : googleAdMobIOSBannerId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: const BannerAdListener(),
        );
        myBanner1.load();
      } else {
        showAds = false;
      }
    }
    await getGroupAdmins();
    setState(() {
      _loading = false;
    });
  }

  getGroupAdmins() {
    if (currentUserInformations.adminMemberGroups.isNotEmpty) {
      isCurrentUserGroupAdmin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(_loading);
    }
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: StreamBuilder(
          stream: _getMyEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            } else if (!snapshot.hasData) {
              return Stack(
                children: [
                  Image.asset(
                    'assets/event/bg1.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  AppBarWidget(
                      textt: MyLocalization().event.tr,
                      imageAddress: 'assets/home/languageGlobe.png',
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LanguageSelectPage()))),
                  Center(
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/event/eventicon.PNG',
                            fit: BoxFit.cover,
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            MyLocalization().noEventText.tr,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EventAddPage())),
                              child: Text(
                                MyLocalization().addEventText.tr,
                                style: const TextStyle(
                                    color: MyColors.kGreenColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  )
                ], //end
              );
            } else if (snapshot.hasData && snapshot.data!.docs.isEmpty ||
                snapshot.hasError) {
              return Stack(
                children: [
                  Image.asset(
                    'assets/event/bg1.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  AppBarWidget(
                      textt: MyLocalization().events.tr,
                      imageAddress: 'assets/home/languageGlobe.png',
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LanguageSelectPage()))),
                  Center(
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/event/eventicon.PNG',
                            fit: BoxFit.cover,
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            MyLocalization().noEventText.tr,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EventAddPage())),
                              child: Text(
                                MyLocalization().addEventText.tr,
                                style: const TextStyle(
                                    color: MyColors.kGreenColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  )
                ], //end
              );
            } else {
              return Stack(
                children: [
                  Image.asset(
                    'assets/event/bg.png',
                    height: 310,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Column(
                    children: [
                      AppBarWidget(
                        textt: MyLocalization().events.tr,
                        imageAddress: 'assets/home/languageGlobe.png',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LanguageSelectPage(),
                          ));
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var document = snapshot.data!.docs[index];
                            String eventId = document.id;
                            String title = document['title'];
                            Timestamp time = document['time'];
                            DateTime date = time.toDate();
                            String description = document['description'];
                            GeoPoint location = document['location'];
                            String groupId = document['groupId'];
                            String createdById = document['createdById'];
                            String image = '';
                            try {
                              image = document.get('image');
                            } catch (_) {}
                            return Column(
                              children: [
                                showAds
                                    ? Visibility(
                                        visible: !kIsWeb && index == 2,
                                        child: SizedBox(
                                          height: 60,
                                          child: AdWidget(ad: myBanner1),
                                        ),
                                      )
                                    : SizedBox(),
                                FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection(FirebaseCollection().groups)
                                      .doc(groupId)
                                      .get(),
                                  builder: ((context, groupShot) {
                                    if (!groupShot.hasData) {
                                      return const Loading();
                                    }
                                    print(index);

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventDetailsPage(
                                              groupId: groupShot.data!.id,
                                              eventId: eventId,
                                              date: formatterDDMMYYYY
                                                  .format(date)
                                                  .toString(),
                                              description: description,
                                              event: title,
                                              eventImage: image,
                                              group: groupShot.data!['name'],
                                              image: groupShot.data!['image'] ??
                                                  "",
                                              location: location,
                                              time: formatterHHMM
                                                  .format(date)
                                                  .toString(),
                                              createdById: createdById,
                                            ),
                                          ),
                                        );
                                      },
                                      child: EventDetailCard(
                                        title: title,
                                        subtitle: description,
                                        location: location,
                                        groupName: groupShot.data!['name'],
                                        eventImage: image,
                                        image: groupShot.data!['image'] ?? "",
                                        date: formatterDDMMYYYY
                                            .format(date)
                                            .toString(),
                                        time: formatterHHMM
                                            .format(date)
                                            .toString(),
                                      ),
                                    );
                                  }),
                                ),
                                Visibility(
                                  visible:
                                      index == snapshot.data!.docs.length - 1,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const EventAddPage(),
                                      ));
                                    },
                                    child: Container(
                                      height: 123,
                                      width: double.infinity,
                                      margin: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffD3E6E0),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                border: Border.all(
                                                    color: MyColors.kGreenColor,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: const Icon(
                                              Icons.add,
                                              color: MyColors.kGreenColor,
                                            ),
                                          ),
                                          Text(
                                            MyLocalization().addEventText.tr,
                                            style: const TextStyle(
                                                color: MyColors.kGreenColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        floatingActionButton: FIlterButton(
          first: MyLocalization().filterEventsModalUndoneButton.tr,
          second: MyLocalization().filterEventsModalDoneButton.tr,
          firstPress: () {
            _getMyEvents = FirebaseFirestore.instance
                .collection(FirebaseCollection().events)
                .where('groupId', whereIn: currentUserInformations.memberGroups)
                .where('time', isGreaterThanOrEqualTo: DateTime.now())
                .orderBy('time', descending: false)
                .snapshots();

            setState(() {});
          },
          secondPress: () {
            _getMyEvents = FirebaseFirestore.instance
                .collection(FirebaseCollection().events)
                .where('groupId', whereIn: currentUserInformations.memberGroups)
                .where('time', isLessThanOrEqualTo: DateTime.now())
                .orderBy('time', descending: false)
                .snapshots();

            setState(() {});
          },
        ),
      ),
    );
  }
}
