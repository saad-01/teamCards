import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Groups/Widgets/description_field_with_label.dart';

class IdeaEditScreen extends StatefulWidget {
  const IdeaEditScreen({
    super.key,
  });

  @override
  State<IdeaEditScreen> createState() => _IdeaEditScreenState();
}

class _IdeaEditScreenState extends State<IdeaEditScreen> {
  _addDevelopmentIdea() async {
    CollectionReference developmentIdea = FirebaseFirestore.instance
        .collection(FirebaseCollection().developmentIdeas);

    await developmentIdea.add({
      'description': _descriptionController.text,
      'title': _titleController.text,
      'state': 'offen',
      'createdById': currentUserInformations.id,
      'createdDateTime': DateTime.now(),
      'personLiked': []
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().addDevelopmentIdeasPageNotificationFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add developmentIdea: $error");
      }
      return error;
    });

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().users)
        .where('roleAdmin', isEqualTo: true)
        .get()
        .then((adminUsers) {
      for (var adminUser in adminUsers.docs) {
        sendPushMessage(adminUser.get('fcmtoken'), "Neue Entwicklungsidee",
            _titleController.text);
        sendFeedbackMailToDeveloper(
            "Neue Entwicklungsidee von ${currentUserInformations.name}: ${_titleController.text}",
            _descriptionController.text,
            context);
      }
    }).then((value) {
      Navigator.pop(context);
      openSuccsessSnackBar(
        context,
        MyLocalization()
            .addDevelopmentIdeasPageNotificationThankYouForEntering
            .tr,
      );
    }).catchError((_) {
      Navigator.pop(context);
      openSuccsessSnackBar(
        context,
        MyLocalization()
            .addDevelopmentIdeasPageNotificationThankYouForEntering
            .tr,
      );
    });
  }


  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String state = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg1.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBarBackArrowWidget(
                    textt: MyLocalization().addIdea.tr,
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyLocalization().subject.tr,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: MyColors.kWhiteColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _titleController,
                          cursorColor: Colors.black,
                          cursorHeight: 20,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            fillColor: MyColors.kWhiteColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            hintText: MyLocalization().subject.tr,
                            suffixIcon: SizedBox(
                              width: 60,
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Image.asset(
                                    "assets/settings/star.png",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                  color: MyColors.kBlackColor, width: .5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                  color: MyColors.kBlackColor, width: .5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DescriptioFieldWithLabel(
                      controller: _descriptionController,
                      title: MyLocalization().description.tr,
                      hintText: MyLocalization().description.tr,
                      colour: Colors.black,
                      minline: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 40),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_titleController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty) {
                            await _addDevelopmentIdea();
                          } else {
                            openErrorSnackBar(
                              context,
                              MyLocalization()
                                  .addDevelopmentIdeasPageNotificationFailure
                                  .tr,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.kGreenColor,
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                    color: MyColors.kBlackColor, width: .2)),
                            foregroundColor: MyColors.kWhiteColor,
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                            minimumSize: const Size(double.infinity, 52)),
                        child: Text(MyLocalization().save.tr)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
