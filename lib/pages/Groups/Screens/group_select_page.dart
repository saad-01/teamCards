import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/localization_service.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../More/Widgets/group_list_card_widget.dart';

class GroupSelectPage extends StatefulWidget {
  const GroupSelectPage({super.key});

  @override
  GroupSelectPageState createState() => GroupSelectPageState();
}

class GroupSelectPageState extends State<GroupSelectPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
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

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg1.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(textt: MyLocalization().invitation.tr),
                const SizedBox(height: 30),
                Text(
                  MyLocalization().inviteText.tr,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(FirebaseCollection().groups)
                          .where('groupAdmin',
                              arrayContains: currentUserInformations.id)
                          .orderBy('name', descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (kDebugMode) {
                          print(snapshot);
                        }
                        if (!snapshot.hasData) {
                          return const Loading();
                        } else if (snapshot.hasData &&
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                                MyLocalization().groupSelectPageNoGroups.tr),
                          );
                        }
                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map(
                            (document) {
                              String name = document['name'];
                              String image = document['image'] ?? "";
                              String subtitle = document['description'] ?? "";
                              String groupId = document.id;

                              return GestureDetector(
                                onTap: () async {
                                  if (kIsWeb) {
                                    var link =
                                        "https://kevindroll.page.link/?link=https://app.kevindroll.de/addMember?groupid=$groupId&apn=de.kevindroll.nachhaltigesfahren&ibi=de.kevindroll.nachhaltigesfahren";
                                    await Clipboard.setData(
                                      ClipboardData(
                                          text:
                                              "Trete der $appName Gruppe: $name über den Link\n $link \nbei und trage auch Du etwas zur grüneren Umwelt bei!"),
                                    ).then((value) {
                                      openSuccsessSnackBar(
                                          context,
                                          MyLocalization()
                                              .inviteMemberPageSuccessSnackbarText
                                              .tr);
                                    });


                                    await analytics.logEvent(
                                        name: "dynamic_link_copied",
                                        parameters: {
                                          'groupId': groupId
                                        }).whenComplete(() {
                                      if (kDebugMode) {
                                        print("Analytics logged");
                                      }
                                    }).onError((error, stackTrace) {
                                      if (kDebugMode) {
                                        print("Analytics error: $error");
                                      }
                                    });
                                  }
                                  else {
                                    var link =
                                        await generateGroupInviteLink(groupId,
                                            LocalizationService().getCurrentLocale().toString().substring(0, 2).toUpperCase());

                                    Share.share(
                                        "Trete der $appName Gruppe: $name über den Link\n $link \nbei und trage auch Du etwas zur grüneren Umwelt bei!",
                                        subject: "Gruppe beitreten"
                                        //sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                                        );
                                    await analytics.logEvent(
                                        name: "dynamic_link_copied",
                                        parameters: {
                                          'groupId': groupId
                                        }).whenComplete(() {
                                      if (kDebugMode) {
                                        print("Analytics logged");
                                      }
                                    }).onError((error, stackTrace) {
                                      if (kDebugMode) {
                                        print("Analytics error: $error");
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: GroupListCard(
                                    title: name,
                                    url: image,
                                    subtitle: subtitle,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
