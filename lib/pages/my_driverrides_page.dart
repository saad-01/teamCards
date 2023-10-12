import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';

import '../constants.dart';
import '../assets/widgets/loading.dart';
import 'Events/Widgets/appbar_back_arrow_widget.dart';
import 'Events/Widgets/filter_button.dart';
import 'Home/Widgets/ride_card.dart';
import 'ride_details_page.dart';

class MyRidesPage extends StatefulWidget {
  const MyRidesPage({super.key});

  @override
  MyRidesPageState createState() => MyRidesPageState();
}

class MyRidesPageState extends State<MyRidesPage> {
  bool _loading = true;
  bool showAds = true;
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  final BannerAd myBanner1 = BannerAd(
    adUnitId: (Platform.isAndroid)
        ? googleAdMobAndroidBannerId
        : googleAdMobIOSBannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );
  bool isDrawerOpen = false;
  Stream<QuerySnapshot<Map<String, dynamic>>> _getRides = FirebaseFirestore
      .instance
      .collection(FirebaseCollection().rides)
      .where('createdById', isEqualTo: currentUserInformations.id)
      .where('departureTime', isGreaterThanOrEqualTo: DateTime.now())
      .orderBy('departureTime', descending: false)
      .snapshots();

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  loadAd() async {
    String role = await MyPref.getRole();
    //load ad when user is free
    if (role == 'free') {
      showAds = true;
      myBanner1.load().then((value) {
        setState(() {
          _loading = false;
        });
      });
    } else {
      showAds = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg1.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBarBackArrowWidget(textt: MyLocalization().myRides.tr),
                const SizedBox(height: 20),
                showAds
                    ? Visibility(
                        visible: !kIsWeb && !_loading,
                        child: SizedBox(
                          height: 60,
                          child: AdWidget(ad: myBanner1),
                        ),
                      )
                    : SizedBox(),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder(
                    stream: _getRides,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loading();
                      } else if (!snapshot.hasData) {
                        if (kDebugMode) {
                          print(snapshot);
                        }
                        return Image.asset(
                          'assets/home/noride.png',
                          fit: BoxFit.contain,
                          height: 150,
                          width: 150,
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.docs.isEmpty) {
                        return Image.asset(
                          'assets/home/noride.png',
                          fit: BoxFit.contain,
                          height: 150,
                          width: 150,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView(
                          children: snapshot.data!.docs.map(
                            (document) {
                              String rideId = document.id;
                              String createdById = document['createdById'];
                              int freeSeats = document['freeSeats'];
                              int offeredSeats = document['offeredSeats'];
                              String eventId = document['eventId'];
                              String description = document['description'];
                              GeoPoint location = document['location'];
                              List passenger = document['passenger'];
                              bool flexibleTimeValue =
                                  document['isFlexibleTime'];
                              Timestamp departureDate =
                                  document['departureTime'];
                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection(FirebaseCollection().users)
                                      .doc(createdById)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot> snapdoc) {
                                    if (!snapdoc.hasData) {
                                      return const Center();
                                    }
                                    String createdByImage =
                                        placeHolderProfileImage;
                                    if (snapdoc.data!.get('image') != "") {
                                      createdByImage =
                                          snapdoc.data!.get('image');
                                    }
                                    return FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection(
                                                FirebaseCollection().events)
                                            .doc(eventId)
                                            .get(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<DocumentSnapshot>
                                                eventDoc) {
                                          if (!eventDoc.hasData) {
                                            return const Center();
                                          }

                                          String groupId =
                                              eventDoc.data!['groupId'];
                                          return FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection(
                                                    FirebaseCollection().groups)
                                                .doc(groupId)
                                                .get(),
                                            builder: (context, groupDoc) {
                                              if (!groupDoc.hasData) {
                                                return const Center();
                                              }
                                              String eventImage = "";
                                              try {
                                                eventImage =
                                                    eventDoc.data!['image'];
                                              } catch (_) {}
                                              return Card(
                                                child: HomeRideCard(
                                                  location: location,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RideDetailsPage(
                                                          eventLocation:
                                                              eventDoc.data![
                                                                  'location'],
                                                          userLastOnline:
                                                              formatterDDMMYYYHHMM
                                                                  .format(snapdoc
                                                                      .data!
                                                                      .get(
                                                                          'lastLogin')
                                                                      .toDate())
                                                                  .toString(),
                                                          location: eventDoc
                                                              .data!
                                                              .get('location'),
                                                          groupName: groupDoc
                                                              .data!
                                                              .get('name'),
                                                          description:
                                                              description,
                                                          rideId: rideId,
                                                          date: formatterDDMMYYYY
                                                              .format(eventDoc
                                                                  .data!
                                                                  .get('time')
                                                                  .toDate())
                                                              .toString(),
                                                          event: eventDoc.data!
                                                              .get('title'),
                                                          createdById:
                                                              createdById,
                                                          createdByName: snapdoc
                                                              .data!
                                                              .get('name'),
                                                          image: createdByImage,
                                                          time: formatterHHMM
                                                              .format(eventDoc
                                                                  .data!
                                                                  .get('time')
                                                                  .toDate())
                                                              .toString(),
                                                          eventId: eventId,
                                                          flexibleTime: const {},
                                                          flexibleTimeValue:
                                                              flexibleTimeValue,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  description: description,
                                                  eventImage: eventImage,
                                                  groupTitle:
                                                      groupDoc.data!['name'],
                                                  freeSeats: freeSeats,
                                                  offeredSeats: offeredSeats,
                                                  passengers: passenger,
                                                  eventTitle:
                                                      eventDoc.data!['title'],
                                                  distance: getDistance(
                                                      location,
                                                      eventDoc
                                                          .data!['location']),
                                                  eventDate:
                                                      formatterDDMMYYYHHMM
                                                          .format(departureDate
                                                              .toDate())
                                                          .toString(),
                                                ),
                                              );
                                            },
                                          );
                                        });
                                  });
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            )
          ], //end
        ),
        floatingActionButton: FIlterButton(
          first: MyLocalization().filterMyRidesModalUndoneButton.tr,
          second: MyLocalization().filterMyRidesModalDoneButton.tr,
          firstPress: () {
            _getRides = FirebaseFirestore.instance
                .collection(FirebaseCollection().rides)
                .where('createdById', isEqualTo: currentUserInformations.id)
                .where('departureTime', isGreaterThanOrEqualTo: DateTime.now())
                .snapshots();

            setState(() {});
          },
          secondPress: () {
            _getRides = FirebaseFirestore.instance
                .collection(FirebaseCollection().rides)
                .where('createdById', isEqualTo: currentUserInformations.id)
                .where('departureTime', isLessThanOrEqualTo: DateTime.now())
                .snapshots();

            setState(() {});
          },
        ),
      ),
    );
  }
}
