import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_details_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';

import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/group_list_card_widget.dart';
import '../Widgets/textfield_with_label.dart';
import 'group_add_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  GroupsPageState createState() => GroupsPageState();
}

class GroupsPageState extends State<GroupsPage> {
  List searchResult = [];

  bool _adLoading = true;
  bool showAds = true;
  final Stream<QuerySnapshot<Map<String, dynamic>>> _getGroups =
      FirebaseFirestore.instance
          .collection(FirebaseCollection().groups)
          .where('member', arrayContains: currentUserInformations.id)
          .snapshots();

  final search = TextEditingController();

  final BannerAd myBanner1 = BannerAd(
    adUnitId: (Platform.isAndroid)
        ? googleAdMobAndroidBannerId
        : googleAdMobIOSBannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  loadAd() async {
    String role = await MyPref.getRole();
    //load ad when user is free
    if (role == 'free') {
      showAds = true;
      myBanner1.load().then((value) {
        setState(() {
          _adLoading = false;
        });
      });
    } else {
      showAds = false;
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
              height: 290,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(
                  textt: MyLocalization().myGroups.tr,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: EditProfileTextField(
                    controller: search,
                    title: '',
                    hintText: MyLocalization().search.tr,
                    url: 'assets/settings/searchicon.png',
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 10),
                showAds
                    ? Visibility(
                        visible: !kIsWeb && !_adLoading,
                        child: SizedBox(
                          height: 60,
                          child: AdWidget(ad: myBanner1),
                        ),
                      )
                    : SizedBox(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: StreamBuilder(
                        stream: _getGroups,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Loading();
                          } else if (!snapshot.hasData) {
                            return Column(
                              children: [
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 4),
                                Text(
                                  MyLocalization().groupPageNoGroups.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                                  snapshot.data!.docs.isEmpty ||
                              snapshot.hasError) {
                            return Column(
                              children: [
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 4),
                                Text(
                                  MyLocalization().groupPageNoGroups.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: snapshot.data!.docs.map((e) {
                                String id = e['createdById'];
                                String title = e['name'] ?? "";
                                List members = e['member'] as List;
                                String url = e['image'] ?? "";
                                String description = e['description'] ?? "";
                                Timestamp createdTime =
                                    e['createdDateTime'] ?? "";
                                return Visibility(
                                  visible: search.text == '' ||
                                      title
                                          .toLowerCase()
                                          .contains(search.text.toLowerCase()),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 30,
                                      right: 30,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return GroupDetailsPage(
                                                groupId: e.id,
                                                group: title,
                                                image: url,
                                                createdDateTime: createdTime,
                                                description: description,
                                              );
                                            } // GroupDetailPage,
                                                    ));
                                          },
                                          child: GroupListCard(
                                            title: title,
                                            subtitle:
                                                "${MyLocalization().participants.tr} : ${members.length}",
                                            url: url,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        }),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GroupAddPage(),
                    ));
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
                            Icons.add,
                            color: MyColors.kGreenColor,
                          ),
                        ),
                        Text(
                          MyLocalization().addGroupText.tr,
                          style: const TextStyle(color: MyColors.kGreenColor),
                        )
                      ],
                    ),
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
