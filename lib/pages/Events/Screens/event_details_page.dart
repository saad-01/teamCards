import 'package:address_search_field/address_search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:nachhaltiges_fahren/pages/Events/Screens/offer_seats.dart';

import 'package:nachhaltiges_fahren/pages/Home/pages/home_page.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:range_slider_flutter/range_slider_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../constants.dart';
import 'package:address_search_field/address_search_field.dart' as ass;
import '../../basic_page.dart';
import '../../ride_select_page.dart';
import '../Widgets/appbar_back_arrow_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventDetailsPage extends StatefulWidget {
  final String group;
  final String event;
  final String date;
  final String time;
  final GeoPoint location;
  final String image;
  final String description;
  final String eventId;
  final String eventImage;
  final String groupId;
  final String createdById;
  const EventDetailsPage({
    Key? key,
    required this.group,
    required this.event,
    required this.date,
    required this.time,
    required this.location,
    required this.image,
    required this.description,
    required this.eventId,
    required this.eventImage,
    required this.groupId,
    required this.createdById,
  }) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

TextEditingController controller = TextEditingController();
late ass.Coords? destinationAddress;
TextEditingController freeSeatsController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
DateTime dateController = DateTime.now();
bool flexibleTimeValue = false;

double _lowerValue = -15;
double _upperValue = 15;
String selectedValue = "";
int _freeSeatsValue = 1;

bool rideOfferShowed = false;
bool _loading = true;
num freeSeats = 0;
num offeredSeats = 0;
num offeredVehicle = 0;
bool dateBeforDepartureDateTime = false;
bool rideOffered = true;
GeoData _locationAdress = GeoData(
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

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool didCreateRide = false;

  getData() async {
    _loading = true;
    controller.text = offeredSeats.toString();
    freeSeatsController.text = freeSeats.toString();

    await getSeats();
    await getLocation();
    await getDateState();
    await _getCurrentLocation();
    setState(() {
      _loading = false;
    });
  }

  getDateState() async {
    rideOffered = true;
    dateBeforDepartureDateTime = false;
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().events)
        .doc(widget.eventId)
        .get()
        .then((event) {
      if (!event['time'].toDate().isBefore(DateTime.now())) {
        dateBeforDepartureDateTime = true;
      }
    });

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .where('eventId', isEqualTo: widget.eventId)
        .where('createdById', isEqualTo: currentUserInformations.id)
        .get()
        .then((rides) {
      if (rides.docs.isNotEmpty) {
        rideOffered = true;
      }
      if (rides.docs.isEmpty) {
        rideOffered = false;
      }
    });
  }

  openMapsSheet(context, launcher.Coords coords, String title) async {
    try {
      final coords = launcher.Coords(37.759392, -122.5107336);
      final availableMaps = await launcher.MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coords,
                        title: title,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  getSeats() async {
    freeSeats = 0;
    offeredSeats = 0;
    offeredVehicle = 0;
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .where('eventId', isEqualTo: widget.eventId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['createdById'] == currentUserInformations.id) {
          didCreateRide = true;
        }
        freeSeats += doc['freeSeats'];
        offeredSeats += doc['offeredSeats'];
        offeredVehicle++;
        if (kDebugMode) {
          print(freeSeats);
        }
      }
    }).onError((error, stackTrace) => openWarningSnackBar(
            context, MyLocalization().eventDetailsPageNotificationError.tr));
  }

  getLocation() async {
    try {
      _locationAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      print(_locationAdress);
    } catch (e) {
      print('LOcation error');
      debugPrint(e.toString());
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
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    if (rideOfferShowed) {
      return addRideWidget();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 460,
                    child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _locationAdress.address.isNotEmpty
                              ? LatLng(_locationAdress.latitude,
                                  _locationAdress.longitude)
                              : const LatLng(37.422,
                                  -122.084), // Specify the latitude and longitude of the desired location
                          zoom: 14.0, // Adjust the zoom level as needed
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('myLocation'),
                            position: _currentLocation.address.isNotEmpty
                                ? LatLng(_currentLocation.latitude,
                                    _currentLocation.longitude)
                                : const LatLng(37.422,
                                    -122.084), // Specify the latitude and longitude of the marker
                          ),
                        }),
                  ),
                  Image.asset(
                    'assets/event/bg1.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  AppBarBackArrowWidget(textt: widget.event),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4,
                            left: 20,
                            right: 20),
                        padding: const EdgeInsets.only(bottom: 20),
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
                                      widget.image,
                                    ),
                                    radius: 25,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      widget.event,
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

                            //
                            Row(
                              children: [
                                Container(
                                  height: 150,
                                  width: 120,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                      color: MyColors.kGreenColor,
                                      image: widget.eventImage.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                widget.eventImage,
                                              ),
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        MyLocalization().offeredSeats.tr,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                            hintText: offeredSeats.toString(),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: MyColors.kGreenColor),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: MyColors.kGreenColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        MyLocalization().freeSeats.tr,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                            hintText: freeSeats.toString(),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: MyColors.kGreenColor),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: MyColors.kGreenColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Text(
                                        MyLocalization().eventDetails.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(MyLocalization().group.tr),
                                      ),
                                      Expanded(
                                        child: Text(widget.group),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            "${MyLocalization().date.tr}/${MyLocalization().time.tr}"),
                                      ),
                                      Expanded(
                                        child: Text(
                                            "${widget.date} ${widget.time}"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            Text(MyLocalization().address.tr),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await openMapsSheet(
                                              context,
                                              launcher.Coords(
                                                  _locationAdress.latitude,
                                                  _locationAdress.longitude),
                                              _locationAdress.address,
                                            );
                                          },
                                          child: Text(_locationAdress.address),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Text(
                                      MyLocalization().description.tr,
                                      style: const TextStyle(
                                          color: MyColors.kBlackColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: .1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: TextField(
                                      controller: descriptionController,
                                      maxLines: 10,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 15),
                                        hintText: widget.description,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                              color: MyColors.kGreenColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                              color: MyColors.kGreenColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 250,
                        color: MyColors.kBackGroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RideSelectPage(
                                      eventLocation: widget.location,
                                      eventId: widget.eventId,
                                      groupName: widget.group,
                                      image: widget.eventImage,
                                      date: widget.date,
                                      title: widget.event,
                                      time: widget.time,
                                    ),
                                  ));
                                },
                                child: Image.asset(
                                  'assets/event/btn2.png',
                                  width: 137,
                                  height: 102,
                                  fit: BoxFit.fill,
                                )),
                            GestureDetector(
                                onTap: () async {
                                  if (didCreateRide) {
                                    openErrorSnackBar(context,
                                        MyLocalization().rideIsCreated.tr);
                                    return;
                                  }
                                  var date = formatterDDMMYYYHHMM
                                      .parse("${widget.date} ${widget.time}");
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (context) => OfferSeats(
                                      eventTitle: widget.event,
                                      eventId: widget.eventId,
                                      eventImage: widget.eventImage,
                                      eventLocation: widget.location,
                                      eventDate: date,
                                      groupName: widget.group,
                                    ),
                                  ));
                                  await getData();
                                },
                                child: Image.asset(
                                  'assets/event/btn1.png',
                                  width: 137,
                                  height: 102,
                                  fit: BoxFit.fill,
                                )),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Visibility(
                visible: widget.createdById == currentUserInformations.id,
                child: InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shadowColor: MyColors.kGreenColor,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: MyColors.kGreenColor,
                                  size: 32,
                                ),
                                title: Text(
                                  MyLocalization()
                                      .eventDetailsPageRemoveDialogTitle
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  MyLocalization()
                                      .eventDetailsPageRemoveDialogText
                                      .tr,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Container(
                                margin: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection(FirebaseCollection().events)
                                        .doc(widget.eventId)
                                        .delete()
                                        .then((value) async {
                                      await FirebaseFirestore.instance
                                          .collection(
                                              FirebaseCollection().rides)
                                          .where('eventId',
                                              isEqualTo: widget.eventId)
                                          .get()
                                          .then((value) async {
                                        for (var doc in value.docs) {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  FirebaseCollection().rides)
                                              .doc(doc.id)
                                              .delete();
                                        }
                                      });
                                    }).then((value) {
                                      Navigator.pushAndRemoveUntil(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const BasicPage(idGetter: 1);
                                      }), (route) => false);
                                    });
                                  },
                                  child: Text(
                                    MyLocalization()
                                        .eventDetailsPageRemoveDialogDeleteButton
                                        .tr,
                                    style: const TextStyle(
                                        color: MyColors.kGreenColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                            Container(
                                margin: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    MyLocalization().cancel.tr,
                                    style: const TextStyle(
                                        color: MyColors.kGreenColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                          ],
                        );
                      },
                    );
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  color: MyColors.kGreenColor, width: 2),
                              borderRadius: BorderRadius.circular(14)),
                          child: const Icon(
                            Icons.delete,
                            color: MyColors.kGreenColor,
                          ),
                        ),
                        Text(
                          MyLocalization()
                              .eventDetailsPageRemoveDialogDeleteButton
                              .tr,
                          style: const TextStyle(color: MyColors.kGreenColor),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isNumeric = false}) {
    if (isNumeric) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RowPicker(
              title: MyLocalization().eventDetailsPagePickerFreeSeatsLable.tr,
              defaultValue: _freeSeatsValue,
              onChangeValue: (v) {
                setState(() {
                  controller.text = v.toString();
                  _freeSeatsValue = v;
                });
              },
            ),
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
            MyLocalization().eventDetailsPageDrivingStartLocationLable.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 5,
          ),
          TextField(
            controller: controller,
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => AddressSearchDialog(
                texts: AddressDialogTexts(
                  cancelText: MyLocalization()
                      .eventDetailsPageAdressSearchCancelButton
                      .tr,
                  continueText: MyLocalization()
                      .eventDetailsPageAdressSearchSaveButton
                      .tr,
                  hintText:
                      MyLocalization().eventDetailsPageAdressSearchHintText.tr,
                  noResultsText: MyLocalization()
                      .eventDetailsPageAdressSearchNoAdressFound
                      .tr,
                ),
                geoMethods: geoMethods,
                controller: controller,
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
      cancelText:
          MyLocalization().eventDetailsPageDateTimePickerCancelButton.tr,
      confirmText: MyLocalization().eventDetailsPageDateTimePickerSaveButton.tr,
      initialDate: DateTime.now(),
      use24HourFormat: true,
      autocorrect: true,
      initialTime: TimeOfDay.now(),
      calendarTitle: MyLocalization().eventDetailsPageDateTimePickerTitle.tr,
      type: DateTimePickerType.dateTime,
      dateMask: 'dd.MM.yyyy HH:mm',
      initialValue: dateController.toString(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      icon: const Icon(Icons.event),
      dateLabelText:
          MyLocalization().eventDetailsPageDateTimePickerDateLable.tr,
      timeLabelText:
          MyLocalization().eventDetailsPageDateTimePickerTimeLable.tr,
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
        if (dateController.isAfter(DateTime.now())) {
          _addRideOffer();
        } else {
          openErrorSnackBar(
              context,
              MyLocalization()
                  .eventDetailsPageNotificationDepartureTimeMustLater
                  .tr);
        }
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
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [MyColors.primaryColor, MyColors.thirdColor])),
        child: Text(
          MyLocalization().eventDetailsPageOfferSeatsSaveButton.tr,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget flexibleTimeWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
                MyLocalization().eventDetailsPageFlexibleTimeCheckBoxLable.tr),
            value: flexibleTimeValue,
            onChanged: (value) {
              setState(() {
                flexibleTimeValue = value!;
                if (kDebugMode) {
                  print(flexibleTimeValue);
                }
              });
            },
          ),
          Visibility(
            visible: flexibleTimeValue,
            child: Column(
              children: [
                RangeSliderFlutter(
                  values: [_lowerValue, _upperValue],
                  rangeSlider: true,
                  tooltip: RangeSliderFlutterTooltip(
                    alwaysShowTooltip: true,
                  ),
                  max: 120,
                  textPositionTop: -100,
                  handlerHeight: 30,
                  trackBar: RangeSliderFlutterTrackBar(
                    activeTrackBarHeight: 8,
                    inactiveTrackBarHeight: 5,
                    activeTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MyColors.primaryColor,
                    ),
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                  ),
                  min: -120,
                  fontSize: 15,
                  textBackgroundColor: MyColors.primaryColor,
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    _lowerValue = (lowerValue > 0) ? 0 : lowerValue;
                    _upperValue = (upperValue < 0) ? 0 : upperValue;
                    setState(() {});
                  },
                ),
                Text(
                  "${MyLocalization().eventDetailsPageFlexibleTimeRange.tr} (+${_upperValue.toString()} / ${_lowerValue.toString()})",
                  style: MyTextstyles.kSubtitleStyle,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldWidget() {
    return Column(
      children: <Widget>[
        _entryField(MyLocalization().eventDetailsPageFreeSeatsLable.tr,
            freeSeatsController,
            isNumeric: true),
        _entryField(MyLocalization().eventDetailsPageDescriptionLable.tr,
            descriptionController),
        _dateTimePickerField(),
        flexibleTimeWidget(),
        _locationWidget()
      ],
    );
  }

  Widget addRideWidget() {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.group,
            style: MyTextstyles.appBarTitleStyle,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            iconSize: 30,
            color: MyColors.primaryColor,
            onPressed: () {
              setState(() {
                rideOfferShowed = false;
              });
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
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
                ),
              ),
            ],
          ),
        ));
  }

  _addRideOffer() async {
    CollectionReference ride =
        FirebaseFirestore.instance.collection(FirebaseCollection().rides);

    ride.add({
      'description': descriptionController.text,
      'freeSeats': int.parse(freeSeatsController.text),
      'offeredSeats': int.parse(freeSeatsController.text),
      'createdById': currentUserInformations.id,
      'eventId': widget.eventId,
      'passenger': [],
      'departureTime': dateController,
      'isFlexibleTime': flexibleTimeValue,
      'flexibleTime': {
        'previous': (flexibleTimeValue) ? _lowerValue : 0,
        'later': (flexibleTimeValue) ? _upperValue : 0
      },
      'location':
          GeoPoint(destinationAddress!.latitude, destinationAddress!.longitude),
      'distance': await getDistance(
          GeoPoint(destinationAddress!.latitude, destinationAddress!.longitude),
          widget.location)
    }).then((value) async {
      openSuccsessSnackBar(
        context,
        MyLocalization().eventDetailsPageNotificationSeatsWillBeOffered.tr,
      );
      offeredVehicle++;
      freeSeats = freeSeats + int.parse(freeSeatsController.text);
      setState(() {
        rideOfferShowed = false;
      });
      await updatePointsAndLevel(PointsPerAction().addRideSeat);
      await createEntryHistoryPoints(
          points: PointsPerAction().addRideSeat, rideAdded: true);
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().eventDetailsPageNotificationSeatsCanNotBeOffered.tr,
      );
      if (kDebugMode) {
        print("Failed to add ride: $error");
      }
    });
  }
}

class RowPicker extends StatefulWidget {
  final String title;
  final int defaultValue;
  final Function(int) onChangeValue;

  const RowPicker(
      {required this.title,
      required this.onChangeValue,
      this.defaultValue = 1,
      Key? key})
      : assert(defaultValue >= 0),
        super(key: key);

  @override
  State<RowPicker> createState() => _RowPickerState();
}

class _RowPickerState extends State<RowPicker> {
  late int _count;
  @override
  void initState() {
    super.initState();
    _count = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const Spacer(),
        Text(_count.toString()),
        const SizedBox(
          width: 15,
        ),
        Row(
          children: [
            OutlinedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(10, 10)),
                ),
                onPressed: () {
                  if (_count < 9) {
                    setState(() {
                      _count += 1;
                    });
                    widget.onChangeValue(_count);
                  } else {
                    openWarningSnackBar(
                        context,
                        MyLocalization()
                            .eventDetailsPageNotificationMaxSeats
                            .tr);
                  }
                },
                child: const Text(
                  "+",
                  style: TextStyle(fontSize: 22),
                )),
            OutlinedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(10, 10)),
                ),
                onPressed: () {
                  if (_count > 1) {
                    setState(() {
                      _count -= 1;
                    });
                    widget.onChangeValue(_count);
                  } else {
                    openWarningSnackBar(
                        context,
                        MyLocalization()
                            .eventDetailsPageNotificationMinSeats
                            .tr);
                  }
                },
                child: const Text(
                  "-",
                  style: TextStyle(fontSize: 22),
                ))
          ],
        )
      ],
    );
  }
}
