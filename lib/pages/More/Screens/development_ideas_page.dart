import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';

import '../../../assets/widgets/loading.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Events/Widgets/filter_button.dart';
import '../Widgets/custom_idea_card.dart';
import 'development_ideas_details_page.dart';
import 'idea_edit_page.dart';

class DevelopmentIdeasPage extends StatefulWidget {
  const DevelopmentIdeasPage({super.key});

  @override
  DevelopmentIdeasPageState createState() => DevelopmentIdeasPageState();
}

class DevelopmentIdeasPageState extends State<DevelopmentIdeasPage> {
  bool _loading = true;
  bool showAds = false;
  List statesToGetData = ['offen', 'in Arbeit'];
  List stateTypes = ['offen', 'in Arbeit', 'Umgesetzt'];

  final BannerAd myBanner1 = BannerAd(
    adUnitId: (Platform.isAndroid)
        ? googleAdMobAndroidBannerId
        : googleAdMobIOSBannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  Stream<QuerySnapshot<Map<String, dynamic>>> _getDevelopmentIdeas =
      FirebaseFirestore.instance
          .collection(FirebaseCollection().developmentIdeas)
          .orderBy('createdDateTime', descending: true)
          .snapshots();
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    if (!kIsWeb) {
      await analytics.logEvent(name: "development_ideas_opened");
    }
    String role = await MyPref.getRole();
    if (role == 'free') {
      showAds = true;
      await myBanner1.load();
    } else {
      showAds = false;
    }
    _getDevelopmentIdeas = FirebaseFirestore.instance
        .collection(FirebaseCollection().developmentIdeas)
        .where('state', whereIn: statesToGetData)
        .orderBy('createdDateTime', descending: true)
        .snapshots();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(_loading);
    }
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
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(
                  textt: MyLocalization().ideas.tr,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const IdeaEditScreen(),
                    ));
                  },
                  child: Container(
                    height: 123,
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MyColors.kWhiteColor,
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
                            Icons.add,
                            color: MyColors.kGreenColor,
                          ),
                        ),
                        Text(
                          MyLocalization().addIdeaText.tr,
                          style: const TextStyle(color: MyColors.kGreenColor),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                showAds ?
                Visibility(
                  visible: !kIsWeb && !_loading,
                  child: SizedBox(
                    height: 60,
                    child: AdWidget(ad: myBanner1),
                  ),
                ): SizedBox(),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      top: 10, left: 50, right: 20, bottom: 10),
                  child: Text(
                    MyLocalization().ideas.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: MyColors.kBlackColor),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _getDevelopmentIdeas,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loading();
                      } else if (!snapshot.hasData) {
                        return Center(
                          child: Text(MyLocalization()
                              .developmentIdeasPageNoIdeasAvailable
                              .tr),
                        );
                      } else if (snapshot.hasData &&
                              snapshot.data!.docs.isEmpty ||
                          snapshot.hasError) {
                        return Center(
                          child: Text(MyLocalization()
                              .developmentIdeasPageNoIdeasAvailable
                              .tr),
                        );
                      }
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map(
                          (document) {
                            String developmentIdeaId = document.id;
                            String title = document['title'] ?? "";
                            String description = document['description'] ?? "";
                            String state = document['state'] ?? "";
                            String createdById = document['createdById'];
                            Timestamp createdDateTime =
                                document['createdDateTime'];
                            List personLiked = document['personLiked'] ?? [];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: CustomIdeaCards(
                                textt: title,
                                url: 'assets/settings/star.png',
                                trailingText: personLiked.length.toString(),
                                subtextt:
                                    'Status: ${state == stateTypes[0] ? MyLocalization().open.tr : state == stateTypes[1] ? MyLocalization().working.tr : MyLocalization().closed.tr}',
                                liked: personLiked
                                    .contains(currentUserInformations.id),
                                icon: Icons.thumb_up,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        DevelopmentIdeaDetailsPage(
                                      developmentIdeaId: developmentIdeaId,
                                      title: title,
                                      createdById: createdById,
                                      createdDateTime: createdDateTime,
                                      description: description,
                                      state: state,
                                    ),
                                  ));
                                },
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        floatingActionButton: FIlterButton(
          first: MyLocalization().openIdeas.tr,
          second: MyLocalization().closedIdeas.tr,
          firstPress: () {
            _getDevelopmentIdeas = FirebaseFirestore.instance
                .collection(FirebaseCollection().developmentIdeas)
                .where('state', whereIn: statesToGetData)
                .orderBy('createdDateTime', descending: true)
                .snapshots();

            setState(() {});
          },
          secondPress: () {
            _getDevelopmentIdeas = FirebaseFirestore.instance
                .collection(FirebaseCollection().developmentIdeas)
                .where('state', isEqualTo: stateTypes[2])
                .snapshots();

            setState(() {});
          },
        ),
      ),
    );
  }
}
