import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/localization_service.dart';
import 'package:nachhaltiges_fahren/pages/Events/Widgets/filter_button.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({
    super.key,
    required this.members,
  });

  final List members;

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final List<Map<String, dynamic>> _data = [];
  bool _loading = true;

  DateTime selectedDateTime = DateTime.now();

  final _fireStore = FirebaseFirestore.instance;

  void selectDateTime(BuildContext context) async {

    String locale = LocalizationService().getCurrentLocale().toString();
    String lang = locale.substring(0, 2).toUpperCase();
    List month = [];
    if(lang == 'EN') {
      month = monthsEN;
    } else if(lang == "DE") {
      month = monthsDE;
    } else {
      month = monthsES;
    }

    await showDialog(context: context, builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.9,
        child: StatefulBuilder(
          builder: (context, rebuild) {
            return AlertDialog(
              title: Center(
                child: Text(
                  MyLocalization().month.tr,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 2.5,
                          children: List.generate(month.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                selectedDateTime = DateTime(selectedDateTime.year, index+1);
                                rebuild(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selectedDateTime.month == index + 1
                                      ? Colors.blue
                                      : Colors.white,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  month[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selectedDateTime.month == index + 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              MyLocalization().year.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Expanded(
                              child: YearPicker(
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2099),
                                currentDate: selectedDateTime,
                                initialDate: selectedDateTime,
                                selectedDate: selectedDateTime,
                                onChanged: (value) {
                                  selectedDateTime = DateTime(value.year, selectedDateTime.month);
                                  rebuild(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: MyColors.kWhiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        child: Text(MyLocalization().back.tr),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      );
    });
    await _getData();
  }

  Future<void> _getData() async {
    try {
      _loading = true;
      var members = await _fireStore.collection(FirebaseCollection().users)
          .where('id', whereIn: widget.members).get();
      var rides = await _fireStore.collection(FirebaseCollection().rides)
          .where('createdById', whereIn: widget.members).get();

      if(members.docs.isNotEmpty) {
        _data.clear();
        for(int i = 0; i < members.docs.length; i++) {
          num drivenKm = 0;
          num money = 0;
          if(rides.docs.isNotEmpty) {
            for (var k in rides.docs) {
              if(k.get('createdById') == members.docs[i].get('id')) {
                DateTime time = k.get('departureTime').toDate();
                if(time.month == selectedDateTime.month && time.year == selectedDateTime.year) {
                  drivenKm += k.get('distance');
                }
              }
            }
            money = drivenKm * members.docs[i].get('costPerKM');
          }
          _data.add({
            "name": members.docs[i].get('name'),
            "image": members.docs[i].get('image'),
            "drivenKm": drivenKm,
            "money": money,
          });
        }
      }
      setState(() {
        _data.sort((a, b) => b['drivenKm'].compareTo(a['drivenKm']));
        _loading = false;
      });
    } catch(e) {
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    if(_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg1.png',
              height: 280,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(
                  textt: "  ${MyLocalization().checkBilling.tr}",
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      selectDateTime(context);
                      setState(() {});
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
                              '${selectedDateTime.month} - ${selectedDateTime.year}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: MyColors.kWhiteColor,
                            border: Border.all(color: MyColors.kBlackColor, width: .3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.16,
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Image.network(
                                      _data[index]['image'],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _data[index]['name'],
                                              maxLines: 2,
                                              style:const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: MyColors.kGreenColor),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.035,
                                              width:  MediaQuery.of(context).size.width * 0.08,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: index > 3 ? Colors.grey : MyColors.kGreenColor,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                (index+1).toString(),
                                                style: TextStyle(
                                                  color: index > 3 ? Colors.black : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              "${MyLocalization().distance.tr}: ",
                                              style:  const TextStyle(
                                                  fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${_data[index]['drivenKm'].toStringAsFixed(2)} Km",
                                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              "${MyLocalization().earnedMoney.tr}: ",
                                              style:  const TextStyle(
                                                  fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${_data[index]['money'].toStringAsFixed(2)}\$",
                                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FIlterButton(
          first: MyLocalization().distance.tr,
          second: MyLocalization().earnedMoney.tr,
          firstPress: () {
            _data.sort((a, b) => b['drivenKm'].compareTo(a['drivenKm']));
            setState(() {});
          },
          secondPress: () {
            _data.sort((a, b) => b['money'].compareTo(a['money']));
            setState(() {});
          },
        ),
      ),
    );
  }
}
