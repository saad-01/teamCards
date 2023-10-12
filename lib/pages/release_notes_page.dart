import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import 'Events/Widgets/appbar_back_arrow_widget.dart';

class ReleaseNotesPage extends StatefulWidget {
  const ReleaseNotesPage({super.key});

  @override
  ReleaseNotesPageState createState() => ReleaseNotesPageState();
}

class ReleaseNotesPageState extends State<ReleaseNotesPage> {
  final List<Item> _data = [
    Item(
        expandedValue: MyLocalization().relaseNotesItem19.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 2.0.0"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem18.tr,
        headerValue:
            "${MyLocalization().relaseNotesVersion.tr} 1.3.12 und 1.3.13"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem17.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.11"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem16.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.10"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem15.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.9"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem14.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.8"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem13.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.7"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem12.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.6"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem11.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.5"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem10.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.4"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem9.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.3"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem8.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.3.0"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem7.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.2.5"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem6.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.2.4"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem5.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.2.0"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem4.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.1.2"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem3.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.1.1"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem2.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.1.0"),
    Item(
        expandedValue: MyLocalization().relaseNotesItem1.tr,
        headerValue: "${MyLocalization().relaseNotesVersion.tr} 1.0.9"),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
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
                      textt: '   ${MyLocalization().releaseNotesPageTitle.tr}'),
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _data[index].isExpanded = isExpanded;
                      });
                    },
                    expandIconColor: MyColors.kGreenColor,
                    children: _data.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              item.headerValue,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            textColor: MyColors.kGreenColor,
                          );
                        },
                        body: ListTile(
                          title: Text(item.expandedValue),
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
