import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import '../../Home/Widgets/appbar_widget.dart';

class MyRideFilterScreen extends StatefulWidget {
  const MyRideFilterScreen({super.key});

  @override
  State<MyRideFilterScreen> createState() => _MyRideFilterScreenState();
}

class _MyRideFilterScreenState extends State<MyRideFilterScreen> {
  int selectIndex = 2;

  DateTime? selectedDateTime = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg1.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            AppBarWidget(
                textt: MyLocalization().myRides.tr,
                imageAddress: 'assets/home/languageGlobe.png',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LanguageSelectPage(),
                  ));
                }),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 210,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MyColors.kWhiteColor,
                        border: Border.all(color: MyColors.kBlackColor, width: .3),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Card(
                              borderOnForeground: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: MyColors.kGreenColor, width: 0.3)),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    selectDateTime(context);
                                  },
                                  child: Image.asset(
                                    'assets/event/eventlogo.PNG',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    const Text(
                                      '|\t\t',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w200),
                                    ),
                                    // '${selectedDateTime ?? ''}',
                                    Text(
                                      MyLocalization().futureRides.tr,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Card(
                              borderOnForeground: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: MyColors.kGreenColor, width: 0.3)),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    selectDateTime(context);
                                  },
                                  child: Image.asset(
                                    'assets/event/eventlogo.PNG',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    const Text(
                                      '|\t\t',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w200),
                                    ),
                                    // '${selectedDateTime ?? ''}',
                                    Text(
                                      MyLocalization().pastRides.tr,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            MyLocalization().filter.tr,
                            style: const TextStyle(fontSize: 15, color: MyColors.kBlackColor),
                          )
                        ],
                      ),
                    ),
                    //
                    Container(
                      margin: const EdgeInsets.all(20),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: MyColors.kGreenColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.highlight_remove_sharp,
                        size: 35,
                        color: MyColors.kWhiteColor,
                      ),
                    )
                  ],
                ),
              ),
            )
          ], //end
        ),
      ),
    );
  }
}
