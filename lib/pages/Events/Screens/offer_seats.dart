import 'dart:math';

import 'package:address_search_field/address_search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../Widgets/appbar_back_arrow_widget.dart';

class OfferSeats extends StatefulWidget {
  const OfferSeats({
    super.key,
    required this.eventTitle,
    required this.eventImage,
    required this.eventId,
    required this.eventLocation,
    required this.eventDate,
    required this.groupName,
  });

  final String eventId;
  final String eventTitle;
  final String eventImage;
  final GeoPoint eventLocation;
  final DateTime eventDate;
  final String groupName;

  @override
  State<OfferSeats> createState() => _OfferSeatsState();
}

class _OfferSeatsState extends State<OfferSeats> {
  bool _flexibleTime = false;

  int selectIndex = 1;
  int seatVariable = 0;
  final _descriptionController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  final _locationController = TextEditingController();
  Coords? destinationAddress;
  double beforeMinutes = 0;
  double afterMinutes = 0;
  GeoData _currentLocation = GeoData(
    address: "",
    city: "",
    country: "",
    latitude: 0,
    longitude: 0,
    postalCode: "",
    state: "",
    countryCode: "",
    streetNumber: "",
  );

  bool _loading = true;

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDateTime != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void success() {
    openSuccsessSnackBar(
      context,
      MyLocalization().addEventPageNotificationEventCreated.tr,
    );
    _loading = false;
    Navigator.pop(context);
  }

  Future<void> _scheduleNotification(
      int id, String title, String body, DateTime date, String data) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: "ashwin",
            importance: Importance.max,
            priority: Priority.max),
        // iOS details
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle:
          true, //To show// notification even when the app is closed
      payload: data,
    );
  }

  double calculateDistance() {
    var lat1 = widget.eventLocation.latitude;
    var lon1 = widget.eventLocation.longitude;
    var lat2 = destinationAddress!.latitude;
    var lon2 = destinationAddress!.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _addRide() async {
    try {
      if (selectedDateTime.isBefore(DateTime.now())) {
        openErrorSnackBar(
            context,
            MyLocalization()
                .eventDetailsPageNotificationDepartureTimeMustLater
                .tr);
        return;
      }
      _loading = true;
      // if(widget.eventLocation.longitude == destinationAddress!.longitude
      //     && widget.eventLocation.latitude == destinationAddress!.latitude) {
      //   openErrorSnackBar(
      //     context,
      //     MyLocalization().addEventPageNotificationEventNotCreated.tr,
      //   );
      //   return;
      // }

      CollectionReference rides =
          FirebaseFirestore.instance.collection(FirebaseCollection().rides);
      await rides.add({
        "createdById": currentUserInformations.id,
        "departureTime": selectedDateTime,
        "description": _descriptionController.text,
        "distance": calculateDistance(),
        "eventId": widget.eventId,
        "freeSeats": seatVariable,
        "isFlexibleTime": _flexibleTime,
        "location": GeoPoint(
            destinationAddress!.latitude, destinationAddress!.longitude),
        "flexibleTime": {
          "previous": beforeMinutes.toInt(),
          "later": afterMinutes.toInt(),
        },
        "offeredSeats": seatVariable,
        "passenger": [],
      }).then((value) async {
        if ((await SharedPreferences.getInstance()).getBool('notifs') ?? true) {
          String payload = "${widget.eventLocation},"
              "${formatterDDMMYYYHHMM.format(currentUserInformations.lastLogin.toDate()).toString()},"
              "${currentUserInformations.id},"
              "$destinationAddress,"
              "${widget.groupName},"
              "${_descriptionController.text},"
              "${value.id},"
              "${formatterDDMMYYYY.format(selectedDateTime).toString()},"
              "${widget.eventTitle},"
              "${currentUserInformations.name},"
              "${currentUserInformations.image},"
              "${formatterHHMM.format(selectedDateTime).toString()},"
              "${widget.eventId},"
              "$_flexibleTime,"
              "${beforeMinutes.toString()} ${afterMinutes.toString()}";
          print(payload);
          print(payload.split(','));
          var dateTime = selectedDateTime.add(const Duration(hours: -1));
          await _scheduleNotification(
            Random().nextInt(9999),
            'Appointment for the ride',
            _descriptionController.text,
            dateTime,
            payload,
          ).then((value) => success()).catchError((_) {
            success();
          });
        } else {
          success();
        }
      });
    } catch (e, str) {
      print(e);
      print(str);
      _loading = false;
      openErrorSnackBar(
        context,
        MyLocalization().addEventPageNotificationEventNotCreated.tr,
      );
    }
  }

  _getCurrentLocation() async {
    try {
      final data = await Geolocator.getCurrentPosition();
      _currentLocation = await Geocoder2.getDataFromCoordinates(
        latitude: data.latitude,
        longitude: data.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      _locationController.text = _currentLocation.address;
      destinationAddress = Coords(data.latitude, data.longitude);
      setState(() {
        _loading = false;
      });
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    var newDate = widget.eventDate.add(const Duration(hours: -1));
    selectedDateTime = newDate;
    _getCurrentLocation();
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
              height: 310,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            ListView(
              children: [
                AppBarBackArrowWidget(textt: MyLocalization().offerSeat.tr),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  decoration: BoxDecoration(
                      color: MyColors.kWhiteColor,
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: MyColors.kWhiteColor,
                              backgroundImage: NetworkImage(
                                widget.eventImage,
                              ),
                              radius: 25,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                widget.eventTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.kGreenColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Text(
                          MyLocalization().description.tr,
                          style: const TextStyle(
                              color: MyColors.kBlackColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: .1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 10,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintText: MyLocalization().description.tr,
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: MyColors.kGreenColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: MyColors.kGreenColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      //
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            selectDateTime(context);
                          },
                          child: Card(
                            borderOnForeground: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: MyColors.kGreenColor, width: 0.3)),
                            child: ListTile(
                              leading: Image.asset(
                                'assets/event/eventlogo.PNG',
                                width: 35,
                                height: 35,
                                fit: BoxFit.fill,
                              ),
                              title: Row(
                                children: [
                                  const Text(
                                    '|\t\t',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  Text(
                                    formatterDDMMYYYHHMM
                                        .format(selectedDateTime),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      //
                      Text(
                        MyLocalization().freeSeats.tr,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: MyColors.kGreenColor,
                        ),
                      ),
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                if (seatVariable > 0) {
                                  setState(() {
                                    seatVariable--;
                                  });
                                }
                              },
                              child: const Icon(Icons.remove_circle_outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 5),
                            child: Card(
                              child: SizedBox(
                                  width: 100,
                                  height: 30,
                                  child: Center(
                                      child: Text(
                                    seatVariable.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ))),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  seatVariable++;
                                });
                              },
                              child: const Icon(Icons.add_circle_outline)),
                        ],
                      ),
                      //

                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Text(
                          MyLocalization().departureAddress.tr,
                          style: const TextStyle(
                              color: MyColors.kBlackColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      //address card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
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
                                controller: _locationController,
                                onDone: (Address address) {
                                  destinationAddress = address.coords;
                                  setState(() {});
                                },
                              ),
                            );
                          },
                          child: Card(
                            borderOnForeground: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: MyColors.kGreenColor, width: 0.3)),
                            child: ListTile(
                              trailing: GestureDetector(
                                child: Image.asset(
                                  'assets/event/departureicon.png',
                                  width: 25,
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              title: Text(
                                _locationController.text,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //flexible tag
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              MyLocalization().flexibleTime.tr,
                              style: const TextStyle(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                _flexibleTime = !_flexibleTime;
                                setState(() {});
                              },
                              child: Container(
                                height: 18,
                                width: 18,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: MyColors.kGreenColor),
                                ),
                                child: Visibility(
                                  visible: _flexibleTime,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: MyColors.kGreenColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: _flexibleTime,
                        child: Column(
                          children: [
                            Card(
                              borderOnForeground: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: MyColors.kGreenColor, width: 0.3)),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "${beforeMinutes.toInt()} ${MyLocalization().minutes.tr} ${MyLocalization().previous.tr}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.kGreenColor,
                                    ),
                                  ),
                                  Slider(
                                    max: 60,
                                    min: 0,
                                    value: beforeMinutes,
                                    onChanged: (value) =>
                                        setState(() => beforeMinutes = value),
                                    activeColor: MyColors.kGreenColor,
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              borderOnForeground: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: MyColors.kGreenColor, width: 0.3)),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "${afterMinutes.toInt()} ${MyLocalization().minutes.tr} ${MyLocalization().later.tr}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.kGreenColor,
                                    ),
                                  ),
                                  Slider(
                                    max: 60,
                                    min: 0,
                                    value: afterMinutes,
                                    onChanged: (value) =>
                                        setState(() => afterMinutes = value),
                                    activeColor: MyColors.kGreenColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0)
                            .copyWith(bottom: 20, top: 10),
                        child: ElevatedButton(
                            onPressed: () async => await _addRide(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.kGreenColor,
                                foregroundColor: MyColors.kWhiteColor,
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                                minimumSize: const Size(double.infinity, 50)),
                            child: Text(MyLocalization().offer.tr)),
                      ),
                    ],
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
