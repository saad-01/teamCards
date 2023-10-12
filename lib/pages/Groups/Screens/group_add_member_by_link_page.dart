// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';

import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../basic_page.dart';

class GroupAddMemberByLinkPage extends StatefulWidget {
  const GroupAddMemberByLinkPage({Key? key, required this.groupId})
      : super(key: key);
  final String groupId;
  @override
  State<GroupAddMemberByLinkPage> createState() =>
      _GroupAddMemberByLinkPageState();
}

class _GroupAddMemberByLinkPageState extends State<GroupAddMemberByLinkPage> {
  String groupName = "";
  String groupImage = placeHolderProfileImage;
  bool groupExist = true;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    await getUserData();
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .doc(widget.groupId)
        .get()
        .then((group) {
      if (group.exists) {
        if (group['image'] != "") {
          groupImage = group['image'];
        }
        groupName = group['name'];
      } else {
        groupExist = false;
        groupName =
            MyLocalization().addGroupMemberByLinkPageGroupNameIfNotAvailable.tr;
      }
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    Size size = MediaQuery.of(context).size;
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
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    AppBarBackArrowWidget(
                      textt: MyLocalization().addGroupMemberByLinkPageTitle.tr,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.2),
                          Container(
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    groupImage,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  radius: 60,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  groupName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.05),
                          Visibility(
                              visible: !groupExist,
                              child: Text(MyLocalization()
                                  .addGroupMemberByLinkPageTextIfNotAvailable
                                  .tr)),
                          Visibility(
                            visible: groupExist,
                            child: GestureDetector(
                              onTap: () async {
                                _addGroup(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: MyColors.kGreenColor,
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(
                                  MyLocalization()
                                      .addGroupMemberByLinkPageAddGroupButton
                                      .tr,
                                  style:
                                      const TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addGroup(context) async {
    FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .doc(widget.groupId)
        .update({
      'member': FieldValue.arrayUnion([currentUserInformations.id])
    }).then((value) {
      openSuccsessSnackBar(
          context,
          MyLocalization()
              .addGroupMemberByLinkPageNotificationGroupAddedSuccessfull
              .tr);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const BasicPage(
                  idGetter: 0,
                )),
      );
    }).onError((error, stackTrace) {
      openErrorSnackBar(
          context,
          MyLocalization()
              .addGroupMemberByLinkPageNotificationGroupAddedFailure
              .tr);
    });
  }
}
