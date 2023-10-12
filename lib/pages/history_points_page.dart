import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../constants.dart';

class HistoryPointsPage extends StatefulWidget {
  const HistoryPointsPage({super.key});

  @override
  HistoryPointsPageState createState() => HistoryPointsPageState();
}

class HistoryPointsPageState extends State<HistoryPointsPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool _loading = true;
  bool isDrawerOpen = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    await getUserData();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            MyLocalization().historyPointsPageTitle.tr,
            style: GoogleFonts.racingSansOne(
                fontSize: 36, color: MyColors.primaryColor),
          ),
          backgroundColor: Colors.white60,
          elevation: 0,
          leading: IconButton(
            iconSize: 30,
            color: MyColors.primaryColor,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(FirebaseCollection().historyPoints)
                .where('userId', isEqualTo: currentUserInformations.id)
                .orderBy('createdDateTime', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (kDebugMode) {
                print(snapshot);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loading();
              }
              else if (!snapshot.hasData) {
                return Center(
                  child: Text(
                      textAlign: TextAlign.center,
                      MyLocalization().historyPointsNoPointsHistory.tr),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                      textAlign: TextAlign.center,
                      MyLocalization().historyPointsNoPointsHistory.tr),
                );
              }

              int tileNum = 0;

              return ListView(
                padding: const EdgeInsets.all(16),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: snapshot.data!.docs.map(
                  (document) {
                    Timestamp createdDateTime = document['createdDateTime'];
                    int points = document['points'];
                    bool rideAdded = document['rideAdded'];
                    bool rideRemoved = document['rideRemoved'];
                    bool seatGetIn = document['seatGetIn'];
                    bool seatGetOut = document['seatGetOut'];

                    String text = "";

                    if (rideAdded) {
                      text = MyLocalization()
                          .historyPointsItemHeadlineRideAdded
                          .tr;
                    }
                    if (rideRemoved) {
                      text = MyLocalization()
                          .historyPointsItemHeadlineRideRemoved
                          .tr;
                    }
                    if (seatGetIn) {
                      text = MyLocalization()
                          .historyPointsItemHeadlineSeatGetIn
                          .tr;
                    }
                    if (seatGetOut) {
                      text = MyLocalization()
                          .historyPointsItemHeadlineSeatGetOut
                          .tr;
                    }
                    tileNum++;
                    return timeLineItem(
                      (points > 0)
                          ? "+$points ${MyLocalization().historyPointsItemHeadlinePointsLable.tr}"
                          : "$points ${MyLocalization().historyPointsItemHeadlinePointsLable.tr}",
                      formatterDDMMYYYHHMM
                          .format(createdDateTime.toDate())
                          .toString(),
                      text,
                      (tileNum) == 1,
                      (tileNum) == snapshot.data!.docs.length,
                      points,
                    );
                  },
                ).toList(),
              );
            },
          ),
        ));
  }

  TimelineTile timeLineItem(
    String headline,
    String date,
    String subtitle,
    bool first,
    bool last,
    int pointChange,
  ) {
    return TimelineTile(
      isFirst: first,
      isLast: last,
      alignment: TimelineAlign.start,
      indicatorStyle: IndicatorStyle(
          iconStyle:
              IconStyle(iconData: (pointChange > 0) ? Icons.add : Icons.remove),
          color:
              (pointChange > 0) ? Colors.green.shade300 : Colors.red.shade200),
      endChild: Container(
        margin: const EdgeInsets.all(10),
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headline,
                style: MyTextstyles.kTitleStyle,
              ),
              Text(
                date,
                style: MyTextstyles.kSubtitleStyle,
              ),
            ],
          ),
          Text(
            subtitle,
            style: MyTextstyles.kSubtitleStyle,
          )
        ]),
      ),
    );
  }
}
