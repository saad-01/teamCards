import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/pages/Events/Widgets/appbar_back_arrow_widget.dart';

import '../../../constants.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  final List<Item> _data = [
    Item(
        expandedValue: MyLocalization().helpPageItemAddGroupText.tr,
        headerValue: MyLocalization().helpPageItemAddGroupTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemInviteMemberText.tr,
        headerValue: MyLocalization().helpPageItemInviteMemberTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemAddEventText.tr,
        headerValue: MyLocalization().helpPageItemAddEventTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemLevelText.tr,
        headerValue: MyLocalization().helpPageItemLevelTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemFeedbackText.tr,
        headerValue: MyLocalization().helpPageItemFeedbackTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemFunctionwishText.tr,
        headerValue: MyLocalization().helpPageItemFunctionwishTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemEnterGroupText.tr,
        headerValue: MyLocalization().helpPageItemEnterGroupTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemPointsRewardsText.tr,
        headerValue: MyLocalization().helpPageItemPointsRewardsTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemNewFunctionsText.tr,
        headerValue: MyLocalization().helpPageItemFunctionwishTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemErrorMessageText.tr,
        headerValue: MyLocalization().helpPageItemErrorMessageTitle.tr),
    Item(
        expandedValue: MyLocalization().helpPageItemAddChatText.tr,
        headerValue: MyLocalization().helpPageItemAddChatTitle.tr),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppBarBackArrowWidget(
                      textt: '   ${MyLocalization().help.tr}'),
                ),
                SliverFillRemaining(
                  child: SingleChildScrollView(
                    child: ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _data[index].isExpanded = isExpanded;
                        });
                      },
                      expandIconColor: MyColors.kGreenColor,
                      children: _data.map<ExpansionPanel>((Item item) {
                        return ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                              title: Text(
                                item.headerValue,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                  ),
                ),
              ],
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
