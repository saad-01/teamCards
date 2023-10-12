import 'package:address_search_field/address_search_field.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../assets/widgets/loading.dart';
import 'ride_details_page.dart';

class RideSelectPage extends StatefulWidget {
  const RideSelectPage({
    super.key,
    required this.eventId,
    required this.groupName,
    required this.image,
    required this.title,
    required this.time,
    required this.date,
    required this.eventLocation,
  });
  final String eventId;
  final String groupName;
  final String image;
  final String title;
  final String time;
  final String date;
  final GeoPoint eventLocation;

  @override
  RideSelectPageState createState() => RideSelectPageState();
}

int _a = 0;

class RideSelectPageState extends State<RideSelectPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool _loading = true;
  bool isDrawerOpen = false;
  int filterDistance = 1000;
  late Coords startAdressCoords;
  late Position currentPosition;

  TextEditingController locationController = TextEditingController();
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              MyLocalization().addEventPageNotificationLocationDisabled.tr)));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                MyLocalization().addEventPageNotificationLocationDenied.tr)));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(MyLocalization()
              .addEventPageNotificationLocationForeverDenied
              .tr)));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currentPosition = position;
      startAdressCoords = Coords(position.latitude, position.longitude);
      locationController.text =
          MyLocalization().rideSelectPageActualPosition.tr;
      setState(() {});
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    await _getCurrentPosition();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: Loading()));
    }
    return Scaffold(
      backgroundColor: MyColors.kGreenColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  locationSelectorContainer(),
                ],
              ),
            ),
            const SizedBox(
              height: 25.0,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -5),
                      blurRadius: 9,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35.0),
                    topRight: Radius.circular(35.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    meansTransportMenu(),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(FirebaseCollection().rides)
                            .where('eventId', isEqualTo: widget.eventId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Loading();
                          } else if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                  MyLocalization().rideSelectPageNoRides.tr),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                  MyLocalization().rideSelectPageNoRides.tr),
                            );
                          }

                          return ListView(
                            children: snapshot.data!.docs.map(
                              (document) {
                                String rideId = document.id;
                                String createdById = document['createdById'];
                                int freeSeats = document['freeSeats'];
                                int offeredSeats = document['offeredSeats'];
                                DateTime date =
                                    document['departureTime'].toDate();
                                String description = document['description'];
                                GeoPoint location = document['location'];
                                List passenger = document['passenger'];
                                bool flexibleTimeValue =
                                    document['isFlexibleTime'];
                                // Map flexibleTime = document['flexibleTime'];
                                return FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection(FirebaseCollection().users)
                                        .doc(createdById)
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapdoc) {
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
                                        future: getDurationDistance(
                                            location,
                                            widget.eventLocation,
                                            startAdressCoords),
                                        builder: (context, snapDur) {
                                          if (!snapDur.hasData) {
                                            return const Center();
                                          }

                                          return Visibility(
                                            visible: filterDistance >=
                                                    snapDur.data!['distance'] ||
                                                _a == 3,
                                            child: TicketContainer(
                                              onTap: () {
                                                if (createdById !=
                                                    currentUserInformations
                                                        .id) {
                                                  var data = snapshot.data!.docs
                                                      .where((element) =>
                                                          element[
                                                              'createdById'] ==
                                                          currentUserInformations
                                                              .id)
                                                      .toList();
                                                  for (var i in data) {
                                                    DateTime date1 =
                                                        i['departureTime']
                                                            .toDate();
                                                    if (date1.year ==
                                                            date.year &&
                                                        date1.month ==
                                                            date.month &&
                                                        date1.day == date.day &&
                                                        date1.hour ==
                                                            date.hour) {
                                                      openErrorSnackBar(
                                                          context,
                                                          MyLocalization()
                                                              .youHaveRide
                                                              .tr);
                                                      return;
                                                    }
                                                  }
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RideDetailsPage(
                                                            location: location,
                                                            groupName: widget
                                                                .groupName,
                                                            description:
                                                                description,
                                                            rideId: rideId,
                                                            date:
                                                                formatterDDMMYYYY
                                                                    .format(
                                                                        date)
                                                                    .toString(),
                                                            event: widget.title,
                                                            eventLocation: widget
                                                                .eventLocation,
                                                            createdByName:
                                                                snapdoc.data!
                                                                    .get(
                                                                        'name'),
                                                            userLastOnline:
                                                                formatterDDMMYYYHHMM
                                                                    .format(snapdoc
                                                                        .data!
                                                                        .get(
                                                                            'lastLogin')
                                                                        .toDate())
                                                                    .toString(),
                                                            createdById:
                                                                createdById,
                                                            image:
                                                                createdByImage,
                                                            time: formatterHHMM
                                                                .format(date)
                                                                .toString(),
                                                            eventId:
                                                                widget.eventId,
                                                            flexibleTime: const {},
                                                            flexibleTimeValue:
                                                                flexibleTimeValue,
                                                          )),
                                                );
                                              },
                                              filterDistance: filterDistance,
                                              eventLocation:
                                                  widget.eventLocation,
                                              startRideLocation: location,
                                              createdByName:
                                                  snapdoc.data!.get('name'),
                                              description: description,
                                              freeSeats: freeSeats,
                                              offeredSeats: offeredSeats,
                                              image: createdByImage,
                                              title: snapdoc.data!.get('name'),
                                              subtitle:
                                                  "Level ${snapdoc.data!.get('level')}",
                                              eventDate: formatterDDMMYYYHHMM
                                                  .format(date)
                                                  .toString(),
                                              passenger: passenger,
                                              fromAdressCoords:
                                                  startAdressCoords,
                                              duration:
                                                  snapDur.data!['duration'],
                                              distance:
                                                  snapDur.data!['distance'],
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                            ).toList(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Map> getDurationDistance(GeoPoint startAdress, GeoPoint eventAdress,
      Coords fromAdressCoords) async {
    /* kDio.Dio dio = kDio.Dio();
    kDio.Options kOptions = kDio.Options(
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials":
            true, // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers":
            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD"
      },
    );
   kDio.Response responseDurationRide = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metrics&origins=${startAdress.latitude},${startAdress.longitude}&destinations=${eventAdress.latitude},${eventAdress.longitude}&key=$googleMapsApiKey",
        options: kOptions);
    var responseDataDurationRide =
        responseDurationRide.data as Map<String, dynamic>;

    kDio.Response responseDistanceStartAdress = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metrics&origins=${fromAdressCoords.latitude},${fromAdressCoords.longitude}&destinations=${startAdress.latitude},${startAdress.longitude}&key=$googleMapsApiKey",
        options: kOptions);
    var responseDataDistanceStartAdress =
        responseDistanceStartAdress.data as Map<String, dynamic>;*/

    Map<String, dynamic> durationDistance = {
      /*"duration": ((responseDataDurationRide['rows'][0]['elements'][0]
                  ['duration']['value']) /
              60)
          .round(),
      "distance": responseDataDistanceStartAdress['rows'][0]['elements'][0]
          ['distance']['value'],*/
      "duration": 60,
      "distance": Geolocator.distanceBetween(
        fromAdressCoords.latitude,
        fromAdressCoords.longitude,
        startAdress.latitude,
        startAdress.longitude,
      ).floor()
    };

    return durationDistance;
  }

  Widget locationSelectorContainer() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.primaryColor.withOpacity(.3),
                        border: Border.all(
                            color: MyColors.primaryColor, width: 3.0),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            MyLocalization().rideSelectPageFromAddressLable.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .apply(color: Colors.black38),
                          ),
                          TextField(
                            controller: locationController,
                            onTap: () => showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  AddressSearchDialog(
                                texts: AddressDialogTexts(
                                    cancelText: MyLocalization()
                                        .addEventPageAdressSearchCancelButton
                                        .tr,
                                    continueText: MyLocalization()
                                        .addEventPageAdressSearchSaveButton
                                        .tr,
                                    hintText: MyLocalization()
                                        .addEventPageAdressSearchHint
                                        .tr,
                                    noResultsText: MyLocalization()
                                        .addEventPageAdressSearchNoResult
                                        .tr),
                                geoMethods: geoMethods,
                                controller: locationController,
                                onDone: (Address address) {
                                  startAdressCoords = address.coords!;

                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget meansTransportMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {'distance': '1 km', 'icon': Icons.route},
      {'distance': '5 km', 'icon': Icons.route},
      {'distance': '10 km', 'icon': Icons.route},
      {
        'distance': MyLocalization().rideSelectPageFilterAllLable.tr,
        'icon': Icons.route
      },
    ];
    return Row(
      children: List.generate(menuItems.length, (f) {
        return Expanded(
          child: InkWell(
            onTap: () {
              switch (f) {
                case 0:
                  filterDistance = 1000;
                  break;
                case 1:
                  filterDistance = 5000;
                  break;
                case 2:
                  filterDistance = 10000;
                  break;
                case 3:
                  filterDistance = 999999999999999;
                  break;
              }

              setState(() {
                _a = f;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 3.0, vertical: 9.0),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: _a == f ? MyColors.kGreenColor : const Color(0xfffafbfc),
                border:
                    _a == f ? const Border() : Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(9.0),
                boxShadow: _a == f
                    ? [
                        BoxShadow(
                            blurRadius: 9.0,
                            color: MyColors.primaryColor,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    menuItems[f]['icon'],
                    color: _a == f ? Colors.white : const Color(0xffa7b7c5),
                  ),
                  const SizedBox(
                    width: 3.0,
                  ),
                  Flexible(
                      child: Text(
                    "${menuItems[f]['distance']}",
                    style: TextStyle(
                      color: _a == f ? Colors.white : const Color(0xffa7b7c5),
                    ),
                  ))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
