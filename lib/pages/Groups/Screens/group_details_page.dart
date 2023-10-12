import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/billing_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_add_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_details_member_page.dart';

import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Messages/Widgets/chat_tile_widget.dart';
import '../../More/Widgets/group_list_card_widget.dart';

class GroupDetailsPage extends StatefulWidget {
  final String group;
  final String description;
  final String image;
  final String groupId;

  final Timestamp createdDateTime;
  const GroupDetailsPage({
    Key? key,
    required this.group,
    required this.image,
    required this.createdDateTime,
    required this.description,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool _loading = true;
  num adminAmount = 0;
  List member = [];
  List adminMember = [];
  final _key = GlobalKey<ScaffoldState>();
  bool showAds = true;
  final BannerAd myBanner1 = BannerAd(
    adUnitId: (Platform.isAndroid)
        ? googleAdMobAndroidBannerId
        : googleAdMobIOSBannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  getData() async {
    String role = await MyPref.getRole();
    if (role == 'free') {
      showAds = true;
      await myBanner1.load();
    } else {
      showAds = false;
    }
    await getAmounts();

    setState(() {
      _loading = false;
    });
  }

  getAmounts() async {
    adminAmount = 0;
    member = [];
    adminMember = [];
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .doc(widget.groupId)
        .get()
        .then((doc) {
      adminAmount = doc['groupAdmin'].length;
      member = doc['member'];
      adminMember = doc['groupAdmin'];
    }).onError((error, stackTrace) => openWarningSnackBar(context,
            MyLocalization().groupDetailsPageNotifiationUnexpectedError.tr));
  }

  void _pop() => Navigator.pop(context);

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
    return SafeArea(
      child: Scaffold(
        key: _key,
        backgroundColor: MyColors.kBackGroundColor,
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
                  textt: MyLocalization().myGroups.tr,
                  pencileUrl: adminMember.contains(currentUserInformations.id)
                      ? 'assets/settings/pencile.png'
                      : null,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GroupAddPage(
                        edit: true,
                        groupId: widget.groupId,
                        admins: adminMember,
                        members: member,
                      ),
                    ));
                  },
                ),
                showAds
                    ? Visibility(
                        visible: !kIsWeb,
                        child: SizedBox(
                          height: 60,
                          child: AdWidget(ad: myBanner1),
                        ),
                      )
                    : SizedBox(),
                Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 40, bottom: 10),
                  child: GroupListCard(
                    title: widget.group,
                    subtitle:
                        "${MyLocalization().participants.tr} : ${member.length}",
                    url: widget.image,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BillingPage(members: member),
                      )),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.kGreenColor,
                      foregroundColor: MyColors.kWhiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: MyColors.kGreenColor, width: 2))),
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: Text(MyLocalization().checkBilling.tr),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: MyColors.kWhiteColor,
                                border: Border.all(
                                    color: MyColors.kWhiteColor, width: .3),
                                borderRadius: BorderRadius.circular(15)),
                            child: ListView.builder(
                              itemCount: member.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection(FirebaseCollection().users)
                                        .doc(member[index])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        String id = snapshot.data!['id'];
                                        String url =
                                            snapshot.data!['image'] ?? "";
                                        String name = snapshot.data!['name'];
                                        String level =
                                            snapshot.data!['level'].toString();
                                        String role = adminMember
                                                .contains(snapshot.data!['id'])
                                            ? "Admin"
                                            : "Member";
                                        return FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection(
                                                    FirebaseCollection().rides)
                                                .where('createdById',
                                                    isEqualTo: id)
                                                .get(),
                                            builder: (context, snapshot) {
                                              num drivenKm = 0;
                                              if (snapshot.hasData) {
                                                for (var i
                                                    in snapshot.data!.docs) {
                                                  drivenKm += i.get('distance');
                                                }
                                              }
                                              return ChatTileWidget(
                                                isAdmin: id !=
                                                        currentUserInformations
                                                            .id &&
                                                    adminMember.contains(
                                                        currentUserInformations
                                                            .id),
                                                name: name,
                                                url: url,
                                                distance:
                                                    '${drivenKm.toInt()} Km',
                                                chatId: widget.groupId,
                                                time: '',
                                                role: role,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupMemberPage(
                                                      memberId: id,
                                                      groupId: widget.groupId,
                                                      name: name,
                                                      level: level,
                                                      image: url,
                                                      adminView:
                                                          adminMember.contains(
                                                              currentUserInformations
                                                                  .id),
                                                    ),
                                                  ));
                                                },
                                                onMenuPress: () async {
                                                  print(id);
                                                  print(member);
                                                  member.remove(id);
                                                  print(member);
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          FirebaseCollection()
                                                              .groups)
                                                      .doc(widget.groupId)
                                                      .update({
                                                    "member": member,
                                                  });
                                                  setState(() {});
                                                },
                                              );
                                            });
                                      } else {
                                        return const Loading();
                                      }
                                    });
                              },
                            )),
                      ),
                      Container(
                        height: 80,
                        color: MyColors.kWhiteColor,
                        child: Row(
                            mainAxisAlignment:
                                adminMember.contains(currentUserInformations.id)
                                    ? MainAxisAlignment.spaceAround
                                    : MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: adminMember
                                    .contains(currentUserInformations.id),
                                child: ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(MyLocalization()
                                                  .removeGroup
                                                  .tr),
                                              actions: <Widget>[
                                                TextButton(
                                                    onPressed: () async {
                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                FirebaseCollection()
                                                                    .groups)
                                                            .doc(widget.groupId)
                                                            .delete()
                                                            .then((value) {
                                                          openSuccsessSnackBar(
                                                              context,
                                                              MyLocalization()
                                                                  .groupDetailsPageNotificationRemoveGroupSuccessfull
                                                                  .tr);
                                                          Navigator.pop(
                                                              context);
                                                          _pop();
                                                        });
                                                      } catch (_) {
                                                        openErrorSnackBar(
                                                            context,
                                                            MyLocalization()
                                                                .groupDetailsPageNotificationRemoveGroupFailure
                                                                .tr);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text(
                                                      MyLocalization()
                                                          .groupDetailsPageRemoveGroupButton
                                                          .tr,
                                                      style: const TextStyle(
                                                          color: Colors.red),
                                                    )),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(MyLocalization()
                                                      .groupDetailsPageDialogCancelButton
                                                      .tr),
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 56),
                                        backgroundColor: MyColors.kWhiteColor,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: const BorderSide(
                                                color: MyColors.kGreenColor,
                                                width: 2))),
                                    icon: const Icon(Icons.delete),
                                    label:
                                        Text(MyLocalization().removeGroup.tr)),
                              ),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(MyLocalization()
                                                .groupDetailsPageDialogLeavGroupTitle
                                                .tr),
                                            content: Text(MyLocalization()
                                                .groupDetailsPageDialogLeavGroupQuestion
                                                .tr),
                                            actions: <Widget>[
                                              TextButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            FirebaseCollection()
                                                                .groups)
                                                        .doc(widget.groupId)
                                                        .update({
                                                      'member': FieldValue
                                                          .arrayRemove([
                                                        currentUserInformations
                                                            .id
                                                      ]),
                                                      'groupAdmin': FieldValue
                                                          .arrayRemove([
                                                        currentUserInformations
                                                            .id
                                                      ])
                                                    }).then((_) {
                                                      openSuccsessSnackBar(
                                                          context,
                                                          MyLocalization()
                                                              .groupDetailsPageNotificationLeavGroupSuccessfull
                                                              .tr);
                                                      Navigator.pop(context);
                                                      _pop();
                                                    }).catchError((_) {
                                                      openErrorSnackBar(
                                                          context,
                                                          MyLocalization()
                                                              .groupDetailsPageNotificationLeavGroupFailure
                                                              .tr);
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text(
                                                    MyLocalization()
                                                        .groupDetailsPageDialogLeaveGroupButton
                                                        .tr,
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  )),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(MyLocalization()
                                                    .groupDetailsPageDialogCancelButton
                                                    .tr),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(100, 56),
                                      backgroundColor: MyColors.kGreenColor,
                                      foregroundColor: MyColors.kWhiteColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: const BorderSide(
                                              color: MyColors.kGreenColor,
                                              width: 2))),
                                  icon: const Icon(Icons.logout),
                                  label: Text(MyLocalization()
                                      .groupDetailsPageLeaveGroupButton
                                      .tr)),
                            ]),
                      )
                    ],
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
