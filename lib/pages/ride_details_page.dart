import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:nachhaltiges_fahren/pages/ride_edit_page.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import '../constants.dart';
import 'Messages/Screens/chat_details.dart';

class RideDetailsPage extends StatefulWidget {
  final String createdById;
  final String createdByName;
  final String eventId;
  final String event;
  final String date;
  final String time;
  final String image;
  final String description;
  final String rideId;
  final String groupName;
  final GeoPoint location;
  final String userLastOnline;
  final bool flexibleTimeValue;
  final Map flexibleTime;
  final GeoPoint eventLocation;
  final String distance;

  const RideDetailsPage({
    Key? key,
    required this.createdByName,
    required this.event,
    required this.date,
    required this.time,
    required this.image,
    required this.description,
    required this.rideId,
    required this.groupName,
    required this.location,
    required this.createdById,
    required this.eventId,
    required this.userLastOnline,
    required this.flexibleTimeValue,
    required this.flexibleTime,
    required this.eventLocation,
    this.distance = '',
  }) : super(key: key);

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

late Event currentEvent;
bool createadByIsUser = false;
bool _loading = true;
num freeSeats = 0;
num offeredSeats = 0;
num offeredVehicle = 0;
bool isUserInCar = false;
bool carFull = true;
bool isRiderInEvent = true;
bool dateBeforDepartureDateTime = false;
GeoData _locationAdress = GeoData(
  address: "",
  city: "",
  country: "",
  latitude: 37.422,
  longitude: -122.084,
  postalCode: "",
  state: "",
  countryCode: "",
  streetNumber: "",
);
Position? _currentLocation;

class _RideDetailsPageState extends State<RideDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController scaleController;

  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  double sheetTop = 400;
  double minSheetTop = 30;

  late Animation<double> animation;
  late AnimationController controller;
  forwardAnimation() {
    controller.forward();
    stateBloc.toggleAnimation();
  }

  reverseAnimation() {
    controller.reverse();
    stateBloc.toggleAnimation();
  }

  bool isExpanded = false;
  getSeats() async {
    if (widget.createdById == currentUserInformations.id) {
      createadByIsUser = true;
    } else {
      createadByIsUser = false;
    }
    freeSeats = 0;
    offeredSeats = 0;
    offeredVehicle = 0;
    isUserInCar = false;
    carFull = true;
    dateBeforDepartureDateTime = false;
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .doc(widget.rideId)
        .get()
        .then((doc) {
      freeSeats = doc['freeSeats'];
      offeredSeats = doc['offeredSeats'];
      List passenger = doc['passenger'];

      if (freeSeats != 0) {
        carFull = false;
      }

      if (passenger.contains(currentUserInformations.id)) {
        isUserInCar = true;
      }

      if (!doc['departureTime'].toDate().isBefore(DateTime.now())) {
        dateBeforDepartureDateTime = true;
      }
    }).onError((error, stackTrace) => openWarningSnackBar(
            context, MyLocalization().rideDetailsPageUnexpectedError.tr));
  }

  getLocation() async {
    try {
      _currentLocation = await Geolocator.getCurrentPosition();
      _locationAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      print(_currentLocation?.longitude);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _getData();

    fadeController = AnimationController(
        duration: const Duration(milliseconds: 180), vsync: this);

    scaleController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);

    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(fadeController);
    scaleAnimation = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ));
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: sheetTop, end: minSheetTop)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      });
  }

  _getData() async {
    await getUserData();
    await getSeats();
    await getLocation();
    isRiderInEvent = await isUserRiderInEvent(widget.eventId);
    currentEvent = Event(
      createdById: widget.createdById,
      createdByName: widget.createdByName,
      eventAdress: _locationAdress,
      eventDate: widget.date,
      eventDescirption: widget.description,
      eventName: widget.event,
      eventTime: widget.time,
      groupName: widget.groupName,
      image: widget.image,
      rideId: widget.rideId,
      userLastOnline: widget.userLastOnline,
      flexibleTime: widget.flexibleTime,
      flexibleTimeValue: widget.flexibleTimeValue,
    );
    setState(() {
      _loading = false;
    });
  }

  forward() {
    scaleController.forward();
    fadeController.forward();
  }

  reverse() {
    scaleController.reverse();
    fadeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            StreamBuilder<Object>(
              initialData: StateProvider().isAnimating,
              //stream: stateBloc.animationStatus,
              builder: (context, snapshot) {
                snapshot.data != null ? forward() : reverse();

                return ScaleTransition(
                  scale: scaleAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    _locationAdress.latitude,
                                    _locationAdress
                                        .longitude), // Specify the latitude and longitude of the desired location
                                zoom: 14.0, // Adjust the zoom level as needed
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('myLocation'),
                                  position: _currentLocation != null
                                      ? LatLng(
                                          _currentLocation!.latitude,
                                          _currentLocation!.longitude,
                                        )
                                      : const LatLng(37.422,
                                          -122.084), // Specify the latitude and longitude of the marker
                                ),
                              }),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(20),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: const Icon(Icons.arrow_back,
                                        color: Colors.black),
                                  ),
                                  Visibility(
                                    visible: createadByIsUser,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RideEditPage(
                                                      eventLocation:
                                                          widget.eventLocation,
                                                      rideId: widget.rideId,
                                                      event: widget.event)),
                                        );
                                        await _getData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(20),
                                        backgroundColor: Colors.white,
                                      ),
                                      child: const Icon(Icons.edit,
                                          color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 30),
                              child: _carTitle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              stream: null,
            ),
            Positioned(
              top: animation.value,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  controller.isCompleted
                      ? reverseAnimation()
                      : forwardAnimation();
                },
                onVerticalDragEnd: (DragEndDetails dragEndDetails) {
                  //upward drag
                  if (dragEndDetails.primaryVelocity! < 0.0) {
                    forwardAnimation();
                    controller.forward();
                  } else if (dragEndDetails.primaryVelocity! > 0.0) {
                    //downward drag
                    reverseAnimation();
                  } else {
                    return;
                  }
                },
                child: sheetContainer(),
              ),
            ),
            seatSetButton(),
          ],
        ),
      ),
    );
  }

  Widget seatSetButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Visibility(
        visible: dateBeforDepartureDateTime && !carFull && !createadByIsUser,
        child: Visibility(
          visible: !isRiderInEvent || isUserInCar,
          child: SizedBox(
            width: 200,
            child: (isUserInCar)
                ? MaterialButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection(FirebaseCollection().rides)
                          .doc(currentEvent.rideId)
                          .update({
                        "passenger": FieldValue.arrayRemove(
                            [currentUserInformations.id]),
                        "freeSeats": (freeSeats + 1)
                      }).whenComplete(() async {
                        openSuccsessSnackBar(
                            context,
                            MyLocalization()
                                .rideDetailsPageNotificationGetOutSuccessfull
                                .tr);
                        await updatePointsAndLevel(
                            -PointsPerAction().useFreeSeat);
                        await createEntryHistoryPoints(
                            points: -PointsPerAction().useFreeSeat,
                            seatGetOut: true);

                        await FirebaseFirestore.instance
                            .collection(FirebaseCollection().users)
                            .doc(currentEvent.createdById)
                            .get()
                            .then((DocumentSnapshot userDoc) async {
                          sendPushMessage(
                              userDoc['fcmtoken'],
                              "Mitfahrer ${currentUserInformations.name} ausgestiegen",
                              currentEvent.eventName,
                              info: {
                                "type": "ride",
                              });
                          if (kDebugMode) {
                            print("Push gesendet an: ${userDoc['fcmtoken']}");
                          }

                          await _getData();
                          setState(() {});
                        });
                      }).onError((error, stackTrace) {
                        openErrorSnackBar(
                            context,
                            MyLocalization()
                                .rideDetailsPageNotificationUnexpectedError
                                .tr);
                      });
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(35)),
                    ),
                    color: MyColors.kGreenColor,
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      MyLocalization().rideDetailsPageGetOutButton.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.4,
                        fontFamily: "arial",
                      ),
                    ),
                  )
                : MaterialButton(
                    onPressed: () async {
                      int actualFree = 0;
                      await FirebaseFirestore.instance
                          .collection(FirebaseCollection().rides)
                          .doc(currentEvent.rideId)
                          .get()
                          .then((value) => actualFree = value['freeSeats']);
                      if (actualFree > 0) {
                        await FirebaseFirestore.instance
                            .collection(FirebaseCollection().rides)
                            .doc(currentEvent.rideId)
                            .update({
                          "passenger": FieldValue.arrayUnion(
                              [currentUserInformations.id]),
                          "freeSeats": (freeSeats - 1)
                        }).whenComplete(() async {
                          openSuccsessSnackBar(
                              context,
                              MyLocalization()
                                  .rideDetailsPageNotificationGetInSuccessfull
                                  .tr);
                          await updatePointsAndLevel(1);
                          await createEntryHistoryPoints(
                              points: PointsPerAction().useFreeSeat,
                              seatGetIn: true);
                          await FirebaseFirestore.instance
                              .collection(FirebaseCollection().users)
                              .doc(currentEvent.createdById)
                              .get()
                              .then((DocumentSnapshot userDoc) async {
                            sendPushMessage(
                                userDoc['fcmtoken'],
                                "Neuer Mitfahrer ${currentUserInformations.name}",
                                currentEvent.eventName);
                            if (kDebugMode) {
                              print("Push gesendet an: ${userDoc['fcmtoken']}");
                            }

                            await _getData();
                            setState(() {});
                          });
                        }).onError((error, stackTrace) {
                          openErrorSnackBar(
                              context,
                              MyLocalization()
                                  .rideDetailsPageNotificationUnexpectedError
                                  .tr);
                        });
                      } else {
                        openErrorSnackBar(context,
                            MyLocalization().rideDetailsPageUnexpectedError.tr);
                        _getData();
                        setState(() {});
                      }
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(35)),
                    ),
                    color: MyColors.kGreenColor,
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      MyLocalization().rideDetailsPageGetInButton.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.4,
                        fontFamily: "arial",
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  _carTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 38),
              children: [
                TextSpan(text: currentEvent.eventName),
                const TextSpan(text: "\n"),
                TextSpan(
                    text: currentEvent.eventDate,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(style: const TextStyle(fontSize: 16), children: [
            TextSpan(
                text: currentEvent.groupName,
                style: const TextStyle(color: Colors.black)),
          ]),
        ),
      ],
    );
  }

  sheetContainer() {
    double sheetItemHeight = 110;
    return Container(
      padding: const EdgeInsets.only(top: 25),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          color: Color(0xfff1f1f1)),
      child: Column(
        children: <Widget>[
          drawerHandle(),
          Expanded(
            flex: 1,
            child: ListView(
              children: <Widget>[
                eventDetails(sheetItemHeight),
                rideDetails(sheetItemHeight),
                Visibility(
                  child: passengerDetails(sheetItemHeight),
                  visible: createadByIsUser,
                ),
                const SizedBox(height: 220),
              ],
            ),
          )
        ],
      ),
    );
  }

  drawerHandle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      height: 3,
      width: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xffd9dbdb)),
    );
  }

  eventDetails(double sheetItemHeight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            MyLocalization().rideDetailsPageEventDetailsLable.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            height: sheetItemHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                InkWell(
                  child: listItem(
                    sheetItemHeight,
                    Icons.person,
                    currentEvent.createdByName,
                  ),
                  onTap: () async {
                    if (!createadByIsUser & isUserInCar) {
                      await FirebaseFirestore.instance
                          .collection(FirebaseCollection().chatRoom)
                          .where('assignedRideId', isEqualTo: widget.rideId)
                          .where('contacts',
                              arrayContains: currentUserInformations.id)
                          .get()
                          .then((value) async {
                        if (value.docs.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                lastOnline: widget.userLastOnline,
                                chatRoomId: value.docs.first.id,
                                otherImage: widget.image,
                                otherName: widget.createdByName,
                                otherUserId: widget.createdById,
                                isSenderMe:
                                    value.docs.first.get('createdByUserId') ==
                                        currentUserInformations.id,
                                drivenKm: "${widget.distance} Km",
                              ),
                            ),
                          );
                        } else {
                          await FirebaseFirestore.instance
                              .collection(FirebaseCollection().chatRoom)
                              .add({
                            'assignedRideId': widget.rideId,
                            'contacts': [
                              currentUserInformations.id,
                              widget.createdById
                            ],
                            'createdByUserId': currentUserInformations.id,
                            'createdDateTime': DateTime.now(),
                            'isUnreadFromRecipient': true,
                            'isUnreadFromSender': false,
                            'lastEditDateTime': DateTime.now()
                          }).then((chatroom) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  lastOnline: currentEvent.userLastOnline,
                                  chatRoomId: chatroom.id,
                                  otherImage: currentEvent.image,
                                  otherName: currentEvent.createdByName,
                                  otherUserId: currentEvent.createdById,
                                  isSenderMe: true,
                                  drivenKm: "${widget.distance} Km",
                                ),
                              ),
                            );
                          });
                        }
                      });
                    }
                  },
                ),
                listItem(
                  sheetItemHeight,
                  Icons.date_range,
                  "${currentEvent.eventDate}\n${currentEvent.eventTime}",
                ),
                Visibility(
                  visible: currentEvent.flexibleTimeValue,
                  child: listItem(
                    sheetItemHeight,
                    Icons.timelapse,
                    "${MyLocalization().eventDetailsPageFlexibleTimeCheckBoxLable.tr}\n+${currentEvent.flexibleTime['later']}/${currentEvent.flexibleTime['previous']}${MyLocalization().rideSelectPageTravelTimeMinute.tr}",
                  ),
                ),
                listItem(
                  sheetItemHeight,
                  Icons.location_history,
                  "${currentEvent.eventAdress.postalCode}\n${currentEvent.eventAdress.city}",
                ),
                listItem(
                  sheetItemHeight,
                  Icons.group,
                  currentEvent.groupName,
                ),
              ],
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                        _locationAdress.latitude, _locationAdress.longitude),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: LatLng(_locationAdress.latitude,
                              _locationAdress.longitude),
                          builder: (ctx) => const Icon(Icons.location_pin),
                          anchorPos: AnchorPos.align(AnchorAlign.center),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  rideDetails(double sheetItemHeight) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 40, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            MyLocalization().rideDetailsPageRideDetailsLable.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            height: sheetItemHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                listItem(
                  sheetItemHeight,
                  Icons.person_add_sharp,
                  "$freeSeats\n${MyLocalization().rideDetailsPageFreeSeats.tr}",
                ),
                listItem(
                  sheetItemHeight,
                  Icons.group,
                  "$offeredSeats\n${MyLocalization().rideDetailsPageOfferedSeats.tr}",
                ),
                Visibility(
                  visible: currentEvent.flexibleTimeValue,
                  child: listItem(
                    sheetItemHeight,
                    Icons.time_to_leave,
                    "${widget.flexibleTime['previous']}\n${MyLocalization().minutes.tr} ${MyLocalization().previous.tr}",
                  ),
                ),
                Visibility(
                  visible: currentEvent.flexibleTimeValue,
                  child: listItem(
                    sheetItemHeight,
                    Icons.time_to_leave,
                    "${widget.flexibleTime['later']}\n${MyLocalization().minutes.tr} ${MyLocalization().later.tr}",
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: MyColors.kGreenColor,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      alignment: Alignment.center,
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      )),
                  onPressed: () {
                    MapsLauncher.launchQuery(_locationAdress.address);
                  },
                  child: Text(
                    MyLocalization().rideDetailsPageStartRouteButton.tr,
                    style:
                        const TextStyle(color: Color(0xffffffff), fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  passengerDetails(double sheetItemHeight) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 40, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            MyLocalization().rideDetailsPagePassengerDetailsLable.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            height: sheetItemHeight,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseCollection().rides)
                  .doc(widget.rideId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Loading();
                }
                if (snapshot.data!.get('passenger').length == 0) {
                  return Center(
                      child: Text(
                          MyLocalization().rideDetailsPageNoPassengers.tr));
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.get('passenger').length,
                  itemBuilder: (context, index) {
                    if (kDebugMode) {
                      print(snapshot.data!.get('passenger'));
                    }
                    if (!snapshot.hasData) {
                      return const Loading();
                    }
                    if (snapshot.data?.get('passenger') == null ||
                        snapshot.data?.get('passenger').length == 0) {
                      return Center(
                        child: Text(
                            MyLocalization().rideDetailsPageNoPassengers.tr),
                      );
                    }

                    return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection(FirebaseCollection().users)
                            .doc(snapshot.data!.get('passenger')[index])
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapdoc) {
                          if (!snapdoc.hasData) {
                            return const Center();
                          }
                          String createdByImage = placeHolderProfileImage;
                          if (snapdoc.data!.get('image') != "") {
                            createdByImage = snapdoc.data!.get('image');
                          }
                          return InkWell(
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.message),
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  FirebaseCollection().chatRoom)
                                              .where('assignedRideId',
                                                  isEqualTo: widget.rideId)
                                              .where('contacts',
                                                  arrayContains:
                                                      currentUserInformations
                                                          .id)
                                              .get()
                                              .then((value) async {
                                            if (value.docs.isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatDetailScreen(
                                                    lastOnline: currentEvent
                                                        .userLastOnline,
                                                    chatRoomId:
                                                        value.docs.first.id,
                                                    otherImage:
                                                        currentEvent.image,
                                                    otherName:
                                                        snapdoc.data!['name'],
                                                    otherUserId: currentEvent
                                                        .createdById,
                                                    isSenderMe: value.docs.first
                                                            .get(
                                                                'createdByUserId') ==
                                                        currentUserInformations
                                                            .id,
                                                    drivenKm:
                                                        "${widget.distance} Km",
                                                  ),
                                                ),
                                              );
                                            } else {
                                              await FirebaseFirestore.instance
                                                  .collection(
                                                      FirebaseCollection()
                                                          .chatRoom)
                                                  .add({
                                                'assignedRideId':
                                                    currentEvent.rideId,
                                                'contacts': [
                                                  currentUserInformations.id,
                                                  snapdoc.data!.id,
                                                ],
                                                'createdByUserId':
                                                    currentUserInformations.id,
                                                'createdDateTime':
                                                    DateTime.now(),
                                                'isUnreadFromRecipient': true,
                                                'isUnreadFromSender': false,
                                                'lastEditDateTime':
                                                    DateTime.now()
                                              }).then((chatroom) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatDetailScreen(
                                                      isSenderMe: true,
                                                      lastOnline: currentEvent
                                                          .userLastOnline,
                                                      chatRoomId: chatroom.id,
                                                      otherImage:
                                                          currentEvent.image,
                                                      otherName: currentEvent
                                                          .createdByName,
                                                      otherUserId: currentEvent
                                                          .createdById,
                                                      drivenKm:
                                                          "${widget.distance} Km",
                                                    ),
                                                  ),
                                                );
                                              });
                                            }
                                          });
                                        },
                                        title: Text(MyLocalization()
                                            .rideDetailsPageContactDriver
                                            .tr),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: Text(MyLocalization()
                                            .rideDetailsPagePassengerRemovedFromCarButton
                                            .tr),
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  FirebaseCollection().rides)
                                              .doc(widget.rideId)
                                              .update({
                                            'passenger': FieldValue.arrayRemove(
                                                [snapdoc.data!.id])
                                          }).whenComplete(() {
                                            openSuccsessSnackBar(
                                                context,
                                                MyLocalization()
                                                    .rideDetailsPageNotificationPassengerRemovedFromCarSuccessfull
                                                    .tr);
                                            sendPushMessage(
                                                snapdoc.data!['fcmtoken'],
                                                "Du wurdest aus dem Auto von ${currentUserInformations.name} entfernt",
                                                "${currentEvent.eventName} - ${currentEvent.eventDate} - ${currentEvent.eventTime}");
                                          }).onError((error, stackTrace) =>
                                                  openErrorSnackBar(
                                                      context,
                                                      MyLocalization()
                                                          .rideDetailsPageNotificationPassengerRemovedFromCarFailure
                                                          .tr));
                                          Navigator.pop(context);
                                          _getData();
                                          setState(() {});
                                        },
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 20),
                              width: sheetItemHeight,
                              height: sheetItemHeight,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(createdByImage),
                                  ),
                                  Text(
                                    snapdoc.data!.get('name'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
          Visibility(
            visible: createadByIsUser,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: MyColors.kGreenColor,
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        alignment: Alignment.center,
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        )),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        _loading = true;
                      });
                      await updatePointsAndLevel(
                          -PointsPerAction().addRideSeat);
                      await createEntryHistoryPoints(
                          points: -PointsPerAction().addRideSeat,
                          rideRemoved: true);
                      List passenger = [];
                      String title = "";
                      DateTime date = DateTime.now();
                      await FirebaseFirestore.instance
                          .collection(FirebaseCollection().rides)
                          .doc(widget.rideId)
                          .get()
                          .then((ride) async {
                        passenger = ride['passenger'];
                        await FirebaseFirestore.instance
                            .collection(FirebaseCollection().events)
                            .doc(ride['eventId'])
                            .get()
                            .then((event) {
                          title = event['title'];
                          date = event['time'].toDate();
                        });
                      });
                      await FirebaseFirestore.instance
                          .collection(FirebaseCollection().rides)
                          .doc(widget.rideId)
                          .delete()
                          .whenComplete(() async {
                        openSuccsessSnackBar(
                            context,
                            MyLocalization()
                                .rideDetailsPageNotificationCancelRideSuccessfull
                                .tr);

                        for (var person in passenger) {
                          await FirebaseFirestore.instance
                              .collection(FirebaseCollection().users)
                              .doc(person)
                              .get()
                              .then((DocumentSnapshot userDoc) {
                            sendPushMessage(
                                userDoc['fcmtoken'],
                                "Fahrt storniert",
                                "$title am ${formatterDDMMYYYY.format(date)}");
                            if (kDebugMode) {
                              print("Push gesendet an: ${userDoc['fcmtoken']}");
                            }
                          });
                        }
                      }).onError((error, stackTrace) {
                        openErrorSnackBar(
                            context,
                            MyLocalization()
                                .rideDetailsPageNotificationUnexpectedError
                                .tr);
                      });
                    },
                    child: Text(
                      MyLocalization().rideDetailsPageCancelRideButton.tr,
                      style: const TextStyle(
                          color: Color(0xffffffff), fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  listItem(double sheetItemHeight, IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      width: sheetItemHeight,
      height: sheetItemHeight,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class StateBloc {
  StreamController animationController = StreamController();
  final StateProvider provider = StateProvider();

  Stream get animationStatus => animationController.stream;

  void toggleAnimation() {
    provider.toggleAnimationValue();
    animationController.sink.add(provider.isAnimating);
  }

  void dispose() {
    animationController.close();
  }
}

final stateBloc = StateBloc();

class StateProvider {
  bool isAnimating = true;
  void toggleAnimationValue() => isAnimating = !isAnimating;
}

double iconSize = 30;

class Event {
  String groupName;
  String eventName;
  String eventDate;
  String eventTime;
  GeoData eventAdress;
  String eventDescirption;
  String createdByName;
  String image;
  String rideId;
  String createdById;
  String userLastOnline;
  bool flexibleTimeValue;
  Map flexibleTime;

  Event({
    required this.groupName,
    required this.eventAdress,
    required this.eventDate,
    required this.eventTime,
    required this.eventName,
    required this.eventDescirption,
    required this.createdById,
    required this.createdByName,
    required this.image,
    required this.rideId,
    required this.userLastOnline,
    required this.flexibleTime,
    required this.flexibleTimeValue,
  });
}
