import 'package:address_search_field/address_search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

import '../assets/widgets/loading.dart';
import 'Events/Widgets/appbar_back_arrow_widget.dart';

class RideEditPage extends StatefulWidget {
  const RideEditPage({
    Key? key,
    required this.rideId,
    required this.event,
    required this.eventLocation,
  }) : super(key: key);
  final String rideId;
  final String event;
  final GeoPoint eventLocation;
  @override
  RideEditPageState createState() => RideEditPageState();
}

class RideEditPageState extends State<RideEditPage> {
  late Position currentPosition;

  final locationController = TextEditingController();
  late Coords? destinationAddress;
  TextEditingController freeSeatsController = TextEditingController();
  TextEditingController offeredSeatsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime dateController = DateTime.now();
  bool _loading = true;
  String selectedValue = "";
  List passenger = [];
  bool _flexibleTime = false;
  double beforeMinutes = 0;
  double afterMinutes = 0;
  getData() async {
    _loading = true;
    passenger = [];
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .doc(widget.rideId)
        .get()
        .then((ride) async {
      descriptionController.text = ride.get('description');
      freeSeatsController.text = ride.get('freeSeats').toString();
      offeredSeatsController.text = ride.get('offeredSeats').toString();
      dateController = ride.get('departureTime').toDate();
      beforeMinutes = ride.get('flexibleTime')['previous'].toDouble() ?? 0;
      afterMinutes = ride.get('flexibleTime')['later'].toDouble() ?? 0;
      _flexibleTime = ride.get('isFlexibleTime');
      try {
        print(ride.get('location').latitude);
        var geoData = await Geocoder2.getDataFromCoordinates(
          latitude: ride.get('location').latitude,
          longitude: ride.get('location').longitude,
          googleMapApiKey: googleMapsApiKey,
        );
        locationController.text = geoData.address;
      } catch (e) {
        print(e);
      }
      destinationAddress = Coords(
        ride.get('location').latitude,
        ride.get('location').longitude,
      );
      passenger = ride.get('passenger');
    });

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isNumeric = false}) {
    if (isNumeric) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration:
                    MyTextInputFieldStyles.getWhiteSpacePrimaryBorder(title))
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              decoration:
                  MyTextInputFieldStyles.getWhiteSpacePrimaryBorder(title))
        ],
      ),
    );
  }

  Widget _locationWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyLocalization().rideEditPageStartAdressLable.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 5,
          ),
          TextField(
            controller: locationController,
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => AddressSearchDialog(
                texts: AddressDialogTexts(
                    cancelText: MyLocalization()
                        .rideEditPageAdressSearchCancelButton
                        .tr,
                    continueText:
                        MyLocalization().rideEditPageAdressSearchSaveButton.tr,
                    hintText: MyLocalization().rideEditPageAdressSearchHint.tr,
                    noResultsText: MyLocalization()
                        .rideEditPageAdressSearchNoAdressFound
                        .tr),
                geoMethods: geoMethods,
                controller: locationController,
                onDone: (Address address) {
                  destinationAddress = address.coords;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTimePicker _dateTimePickerField() {
    return DateTimePicker(
      cancelText: MyLocalization().rideEditPageDateTimePickerCancelButton.tr,
      confirmText: MyLocalization().rideEditPageDateTimePickerSaveButton.tr,
      initialDate: DateTime.now(),
      use24HourFormat: true,
      autocorrect: true,
      initialTime: TimeOfDay.now(),
      calendarTitle: MyLocalization().rideEditPageDateTimePickerTitle.tr,
      type: DateTimePickerType.dateTime,
      dateMask: 'dd.MM.yyyy HH:mm',
      initialValue: dateController.toString(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      icon: const Icon(Icons.event),
      dateLabelText: MyLocalization().rideEditPageDateTimePickerDateLable.tr,
      timeLabelText: MyLocalization().rideEditPageDateTimePickerTimeLable.tr,
      selectableDayPredicate: (date) {
        return true;
      },
      onChanged: (val) {
        setState(() {
          dateController = DateTime.parse(val);
        });

        if (kDebugMode) {
          print(dateController);
        }
      },
      validator: (val) {
        if (kDebugMode) {
          print(val);
        }
        return null;
      },
      onSaved: (val) {
        setState(() {
          dateController = DateTime.parse(val!);
        });
        if (kDebugMode) {
          print(dateController);
        }
      },
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: () async {
        _editRide();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: MyColors.kGreenColor,
        ),
        child: Text(
          MyLocalization().rideEditPageSaveButton.tr,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _fieldWidget() {
    return Column(
      children: <Widget>[
        _entryField(MyLocalization().rideEditPageOfferdSeatsLable.tr,
            offeredSeatsController,
            isNumeric: true),
        _entryField(MyLocalization().rideEditPageDescriptionLable.tr,
            descriptionController),
        _dateTimePickerField(),
        _locationWidget()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SizedBox(
            height: height,
            child: Stack(
              children: <Widget>[
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
                          textt: ' ${MyLocalization().rideEditPageTitle.tr}'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 15),
                            _fieldWidget(),
                            const SizedBox(height: 20),
                            _saveButton(),
                          ],
                        ),
                      ), //flexible tag
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
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  _editRide() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .doc(widget.rideId)
        .update({
      'description': descriptionController.text,
      'offeredSeats': int.parse(offeredSeatsController.text),
      'departureTime': dateController,
      'location':
          GeoPoint(destinationAddress!.latitude, destinationAddress!.longitude),
      'distance': await getDistance(
          GeoPoint(destinationAddress!.latitude, destinationAddress!.longitude),
          widget.eventLocation),
      'isFlexibleTime': _flexibleTime,
      'flexibleTime': {
        "previous": beforeMinutes.toInt(),
        "later": afterMinutes.toInt(),
      },
    }).then((value) async {
      openSuccsessSnackBar(
        context,
        MyLocalization().rideEditPageNotificationSeatsEditSuccessfull.tr,
      );
      for (var user in passenger) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().users)
            .doc(user)
            .get()
            .then((userData) {
          sendPushMessage(userData['fcmtoken'], "Fahrt geändert",
              "${widget.event} - ${formatterDDMMYYYHHMM.format(dateController)}");
        });
      }

      Navigator.pop(context);
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().rideEditPageNotificationSeatsEditFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add ride: $error");
      }
    });
  }
}
