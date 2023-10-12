import 'package:address_search_field/address_search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:im_stepper/stepper.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import '../../../assets/widgets/loading.dart';
import '../Widgets/appbar_back_arrow_widget.dart';

class EventAddPage extends StatefulWidget {
  const EventAddPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  EventAddPageState createState() => EventAddPageState();
}

bool eventRecurring = false;
TextEditingController groupIdController = TextEditingController();
String selectedValue = "";
String selectedCycleValue = "Täglich";
List<DropdownMenuItem<String>> groupMenuItems = [];
DateTime dateController = DateTime.now();
DateTime dateEndController = DateTime.now();
TextEditingController recurringIntervalController = TextEditingController();
TextEditingController recurringAmountController = TextEditingController();
TextEditingController eventController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
late Coords? destinationAddress;
String groupName = "";

getGroupName() async {
  await FirebaseFirestore.instance
      .collection(FirebaseCollection().groups)
      .doc(groupIdController.text)
      .get()
      .then((value) => groupName = value['name']);
}

class EventAddPageState extends State<EventAddPage> {
  bool _loading = true;
  late Position currentPosition;

  TextEditingController locationController = TextEditingController();

  int activeStep = 0;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled().then((value) {
      if (!value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                MyLocalization().addEventPageNotificationLocationDisabled.tr)));
      }
      return !value;
    });

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  MyLocalization().addEventPageNotificationLocationDenied.tr)));
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(MyLocalization()
                .addEventPageNotificationLocationForeverDenied
                .tr)));
      }
      return false;
    }

    return true;
  }

  getUserGroupDropDown() async {
    groupMenuItems.clear();
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .where('groupAdmin', arrayContains: currentUserInformations.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        groupMenuItems
            .add(DropdownMenuItem(value: doc.id, child: Text(doc["name"])));

        selectedValue = doc.id;
        groupIdController.text = doc.id;
        getGroupName();
      }
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      destinationAddress = null;
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      var geoData = await Geocoder2.getDataFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      setState(() {
        currentPosition = position;
        destinationAddress = Coords(position.latitude, position.longitude);
        locationController.text = geoData.address;
      });
    }).catchError((e) {
      print("ERRR");
      debugPrint(e.toString());
    });
  }

  Uint8List byteList = Uint8List(0);
  bool pickedImage = false;
  List<Widget> bodyWidgets = [];

  Widget pickImage() {
    return StatefulBuilder(builder: (context, rebuild) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.image,
                withData: true,
              );

              if (result != null) {
                PlatformFile file = result.files.first;
                byteList = file.bytes!;
                pickedImage = true;
                setState(() {});
                rebuild(() {});
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.kGreenColor,
                foregroundColor: MyColors.kWhiteColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: MyColors.kGreenColor, width: 2))),
            child: Text(MyLocalization().selectImage.tr),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: pickedImage,
            child: SizedBox(
              height: 120,
              width: 150,
              child: Image.memory(Uint8List.fromList(byteList)),
            ),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    groupIdController.text = "";
    eventController.text = "";
    descriptionController.text = "";
    dateController = DateTime.now();
    _getData();
  }

  _getData() async {
    await getUserGroupDropDown();
    await _getCurrentPosition();

    setState(() {
      bodyWidgets = [
        const GroupDropDownWidget(),
        const DateTimeWidget(),
        _entryField(
            title: MyLocalization().addEventPageEventTitleLable.tr,
            textController: eventController),
        _entryField(
            title: MyLocalization().addEventPageDescriptionLable.tr,
            textController: descriptionController),
        _entryField(
          title: MyLocalization().addEventPageAdressLable.tr,
          textController: locationController,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AddressSearchDialog(
                texts: AddressDialogTexts(
                    cancelText: MyLocalization()
                        .addEventPageAdressSearchCancelButton
                        .tr,
                    continueText:
                        MyLocalization().addEventPageAdressSearchSaveButton.tr,
                    hintText: MyLocalization().addEventPageAdressSearchHint.tr,
                    noResultsText:
                        MyLocalization().addEventPageAdressSearchNoResult.tr),
                geoMethods: geoMethods,
                controller: locationController,
                onDone: (Address address) {
                  destinationAddress = address.coords;
                  if (kDebugMode) {
                    print(address.coords);
                  }
                },
              ),
            );
          },
        ),
        pickImage(),
        const SummaryWidget()
      ];

      _loading = false;
    });
  }

  String _getStep() {
    switch (activeStep) {
      case 0:
        return MyLocalization().group.tr;
      case 1:
        return MyLocalization().date.tr;
      case 2:
        return MyLocalization().eventTitle.tr;
      case 3:
        return MyLocalization().description.tr;
      case 4:
        return MyLocalization().location.tr;
      case 5:
        return MyLocalization().image.tr;
      case 6:
        return MyLocalization().summary.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 310,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  AppBarBackArrowWidget(textt: MyLocalization().addEvent.tr),
                  const SizedBox(height: 50),
                  Text(
                    MyLocalization().createEvent.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: MyColors.kWhiteColor,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 2,
                    color: MyColors.kBackGroundColor,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    decoration: BoxDecoration(
                      color: MyColors.kWhiteColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 17),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (activeStep > 0) {
                                    setState(() {
                                      activeStep--;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 67,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 25),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromRGBO(
                                        121, 121, 121, 0.25),
                                  ),
                                  child: const Center(
                                      child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                    size: 20,
                                  )),
                                ),
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 11),
                                    Text(
                                      _getStep(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconStepper(
                          lineColor: MyColors.primaryColor,
                          enableNextPreviousButtons: false,
                          enableStepTapping: false,
                          activeStepBorderColor: Colors.transparent,
                          activeStepColor:
                              const Color.fromRGBO(1, 146, 103, 0.53),
                          stepColor: const Color.fromRGBO(235, 235, 235, 1),
                          stepRadius: 32,
                          icons: [
                            Icon(
                              Icons.group,
                              color:
                                  activeStep == 0 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.date_range,
                              color:
                                  activeStep == 1 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.title,
                              color:
                                  activeStep == 2 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.description,
                              color:
                                  activeStep == 3 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.location_history,
                              color:
                                  activeStep == 4 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.image,
                              color:
                                  activeStep == 5 ? Colors.white : Colors.black,
                            ),
                            Icon(
                              Icons.summarize,
                              color:
                                  activeStep == 6 ? Colors.white : Colors.black,
                            ),
                          ],
                          // activeStep property set to activeStep variable defined above.
                          activeStep: activeStep,
                          // This ensures step-tapping updates the activeStep.
                          onStepReached: (index) {
                            setState(() {
                              activeStep = index;
                            });
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              bodyWidgets[activeStep],
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                      visible:
                                          (activeStep < bodyWidgets.length - 1),
                                      child: Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (selectedValue.isEmpty) {
                                                openErrorSnackBar(
                                                    context,
                                                    MyLocalization()
                                                        .groupPageNoGroups
                                                        .tr);
                                                return;
                                              }
                                              if (activeStep <
                                                  bodyWidgets.length - 1) {
                                                if (activeStep == 2) {
                                                  if (eventController.text !=
                                                      "") {
                                                    setState(() {
                                                      activeStep++;
                                                    });
                                                  } else {
                                                    openErrorSnackBar(
                                                        context,
                                                        MyLocalization()
                                                            .addEventPageNotificationNoTitle
                                                            .tr);
                                                  }
                                                } else if (activeStep == 4) {
                                                  if (destinationAddress !=
                                                      null) {
                                                    setState(() {
                                                      activeStep++;
                                                    });
                                                  } else {
                                                    openErrorSnackBar(
                                                      context,
                                                      MyLocalization()
                                                          .addEventPageNotificationLocationNotValid
                                                          .tr,
                                                    );
                                                  }
                                                } else {
                                                  setState(() {
                                                    activeStep++;
                                                  });
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  MyColors.kGreenColor,
                                              foregroundColor:
                                                  MyColors.kWhiteColor,
                                            ),
                                            child:
                                                Text(MyLocalization().next.tr)),
                                      )),
                                  Visibility(
                                      visible: (activeStep ==
                                          bodyWidgets.length - 1),
                                      child: Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 50.0),
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                if (eventController.text !=
                                                    "") {
                                                  if (dateController.isAfter(
                                                      DateTime.now())) {
                                                    await _addEvent();
                                                  } else {
                                                    openErrorSnackBar(
                                                        context,
                                                        MyLocalization()
                                                            .addEventPageNotificationEventMustInFuture
                                                            .tr);
                                                  }
                                                } else {
                                                  openErrorSnackBar(
                                                      context,
                                                      MyLocalization()
                                                          .addEventPageNotificationNoTitle
                                                          .tr);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.kGreenColor,
                                                foregroundColor:
                                                    MyColors.kWhiteColor,
                                              ),
                                              child: Text(
                                                  MyLocalization().save.tr)),
                                        ),
                                      ))
                                ],
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
      ),
    );
  }

  Future<void> _addEvent() async {
    setState(() {
      _loading = true;
    });
    await eventAdd(dateController).then((_) {
      Navigator.pop(context);
      setState(() {
        _loading = false;
      });
    });

    // if (eventRecurring) {
    //   DateTime selectedDate = dateController;
    //
    //   switch (selectedCycleValue) {
    //     case "Täglich":
    //       while (selectedDate.isBefore(dateEndController)) {
    //         await eventAdd(selectedDate);
    //         selectedDate = DateTime(
    //             selectedDate.year,
    //             selectedDate.month,
    //             selectedDate.day + 1,
    //             selectedDate.hour,
    //             selectedDate.minute,
    //             selectedDate.second);
    //       }
    //
    //       break;
    //     case "Wöchentlich":
    //       while (selectedDate.isBefore(dateEndController)) {
    //         await eventAdd(selectedDate);
    //         selectedDate = DateTime(
    //             selectedDate.year,
    //             selectedDate.month,
    //             selectedDate.day + 7,
    //             selectedDate.hour,
    //             selectedDate.minute,
    //             selectedDate.second);
    //       }
    //       break;
    //     case "Monatlich":
    //       while (selectedDate.isBefore(dateEndController)) {
    //         await eventAdd(selectedDate);
    //         selectedDate = DateTime(
    //             selectedDate.year,
    //             selectedDate.month + 1,
    //             selectedDate.day,
    //             selectedDate.hour,
    //             selectedDate.minute,
    //             selectedDate.second);
    //       }
    //       break;
    //     case "Jährlich":
    //       while (selectedDate.isBefore(dateEndController)) {
    //         await eventAdd(selectedDate);
    //         selectedDate = DateTime(
    //             selectedDate.year + 1,
    //             selectedDate.month,
    //             selectedDate.day,
    //             selectedDate.hour,
    //             selectedDate.minute,
    //             selectedDate.second);
    //       }
    //       break;
    //   }
    //   Navigator.pop(context);
    //   setState(() {
    //     _loading = false;
    //   });
    // } else {
    //
    //
  }

  Future<void> eventAdd(DateTime dateTimeController) async {
    CollectionReference events =
        FirebaseFirestore.instance.collection(FirebaseCollection().events);

    await events.add({
      'description': descriptionController.text,
      'groupId': groupIdController.text,
      'location':
          GeoPoint(destinationAddress!.latitude, destinationAddress!.longitude),
      'time': dateTimeController,
      'title': eventController.text,
      'createdById': currentUserInformations.id,
    }).then((value) async {
      openSuccsessSnackBar(
        context,
        MyLocalization().addEventPageNotificationEventCreated.tr,
      );
      if (pickedImage) {
        var userImage =
            await uploadImageFirestorage("events", groupName, byteList);
        await value.update({"image": userImage});
      }
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().groups)
          .doc(groupIdController.text)
          .get()
          .then((DocumentSnapshot doc) async {
        try {
          var users =
              FirebaseFirestore.instance.collection(FirebaseCollection().users);
          for (var member in doc['member']) {
            users.doc(member).get().then((DocumentSnapshot userDoc) async {
              if (kDebugMode) {
                print("Push gesendet an: ${userDoc['fcmtoken']}");
              }
              final event = await value.get();
              Timestamp time = doc['time'];
              DateTime date = time.toDate();
              String eventImage = '';
              if (pickedImage) {
                eventImage = event.get('image');
              }
              sendPushMessage(userDoc['fcmtoken'], "Neuer Termin in $groupName",
                  "${eventController.text} am ${formatterDDMMYYYY.format(dateTimeController)}",
                  info: {
                    "type": "event",
                    "eventId": value.id,
                    "groupId": groupIdController.text,
                    "eventImage": eventImage,
                    "groupImage": doc['image'],
                    "location": event.get('location'),
                    "description": event.get('description'),
                    "eventName": event.get('title'),
                    "groupName": doc.get('name'),
                    "date": formatterDDMMYYYY.format(date).toString(),
                    "time": formatterHHMM.format(date).toString(),
                  });
            });
          }
        } catch (_) {}
      });
    }).catchError((error) {
      print('SSSSSSSSSSSSSSSSS');
      openErrorSnackBar(
        context,
        MyLocalization().addEventPageNotificationEventNotCreated.tr,
      );
      if (kDebugMode) {
        print("Failed to add event: $error");
      }
    });
  }
}

class GroupDropDownWidget extends StatefulWidget {
  const GroupDropDownWidget({
    super.key,
  });

  @override
  GroupDropDownWidgetState createState() => GroupDropDownWidgetState();
}

class GroupDropDownWidgetState extends State<GroupDropDownWidget> {
  GroupDropDownWidgetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyLocalization().addEventPageGroupLable.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          (groupMenuItems.isNotEmpty)
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MyColors.kGreenColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      const Icon(Icons.group_outlined,
                          color: MyColors.kGreenColor),
                      const SizedBox(width: 5),
                      const Text(
                        "|",
                        style: TextStyle(
                            fontSize: 40,
                            color: MyColors.kGreenColor,
                            fontWeight: FontWeight.w200),
                      ),
                      Expanded(
                        child: DropdownButton(
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          alignment: Alignment.centerLeft,
                          value: selectedValue,
                          hint:
                              Text(MyLocalization().addEventPageGroupLable.tr),
                          items: groupMenuItems,
                          onChanged: (String? newValue) {
                            groupIdController.text = newValue!;

                            selectedValue = newValue;
                            getGroupName();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Text(MyLocalization().groupSelectPageNoGroups.tr),
        ],
      ),
    );
  }
}

class DateTimeWidget extends StatefulWidget {
  const DateTimeWidget({
    super.key,
  });

  @override
  DateTimeWidgetState createState() => DateTimeWidgetState();
}

class DateTimeWidgetState extends State<DateTimeWidget> {
  DateTimeWidgetState();

  void _changeSwitch(bool value) {
    setState(() {
      eventRecurring = !eventRecurring;
    });
    if (kDebugMode) {
      print(eventRecurring);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SwitchListTile(
        //   title: Text(MyLocalization().addEventPageRecurringLable.tr),
        //   value: eventRecurring,
        //   onChanged: (value) {
        //     _changeSwitch(value);
        //   },
        // ),
        Container(
          height: MediaQuery.of(context).size.height * 0.08,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MyColors.kGreenColor, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              const Icon(Icons.date_range, color: MyColors.kGreenColor),
              const SizedBox(width: 5),
              const Text(
                "|",
                style: TextStyle(
                    fontSize: 40,
                    color: MyColors.kGreenColor,
                    fontWeight: FontWeight.w200),
              ),
              Expanded(
                child: DateTimePicker(
                  cancelText: MyLocalization()
                      .addEventPageDateTimePickerCancelButton
                      .tr,
                  confirmText:
                      MyLocalization().addEventPageDateTimePickerSaveButton.tr,
                  initialDate: DateTime.now(),
                  use24HourFormat: true,
                  autocorrect: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  initialTime: TimeOfDay.now(),
                  calendarTitle:
                      MyLocalization().addEventPageDateTimePickerTitle.tr,
                  type: DateTimePickerType.dateTime,
                  dateMask: 'dd.MM.yyyy HH:mm',
                  initialValue: dateController.toString(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryWidget extends StatefulWidget {
  const SummaryWidget({super.key});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  @override
  void initState() {
    super.initState();
    getGroupName();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MyLocalization().addEventPageSummaryLable.tr,
          style: MyTextstyles.kTitleStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            groupName,
            style: MyTextstyles.kSubtitleStyle,
          ),
        ),
        ListTile(
          title: Text(MyLocalization().addEventPageDateLable.tr),
          subtitle:
              Text(formatterDDMMYYYHHMM.format(dateController).toString()),
        ),
        Visibility(
          visible: (eventRecurring),
          child: Text(
            "$selectedCycleValue - ${formatterDDMMYYYHHMM.format(dateEndController)}",
          ),
        ),
        _entryField(
          title: MyLocalization().addEventPageEventTitleLable.tr,
          textController: eventController,
          editable: false,
        ),
        _entryField(
          title: MyLocalization().addEventPageDescriptionLable.tr,
          textController: descriptionController,
          editable: false,
        ),
      ],
    );
  }
}

Widget _entryField({
  required String title,
  required TextEditingController textController,
  VoidCallback? onTap,
  bool editable = true,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      onTap: onTap,
      controller: textController,
      cursorColor: Colors.black,
      readOnly: !editable,
      cursorHeight: 20,
      style: const TextStyle(fontSize: 18, color: Colors.black),
      decoration: InputDecoration(
        fillColor: MyColors.kWhiteColor,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintText: title,
        prefixIcon: SizedBox(
          width: 60,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/settings/editprofile.png",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const Text(
                "|",
                style: TextStyle(
                    fontSize: 40,
                    color: MyColors.kGreenColor,
                    fontWeight: FontWeight.w200),
              )
            ],
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: MyColors.kGreenColor, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: MyColors.kGreenColor, width: .5),
        ),
      ),
    ),
  );
}
