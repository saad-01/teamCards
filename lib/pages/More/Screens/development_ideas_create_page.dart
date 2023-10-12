import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class DevelopmentIdeaAddPage extends StatefulWidget {
  const DevelopmentIdeaAddPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  DevelopmentIdeaAddPageState createState() => DevelopmentIdeaAddPageState();
}

class DevelopmentIdeaAddPageState extends State<DevelopmentIdeaAddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    titleController.text = "";
    descriptionController.text = "";

  }


  Widget _entryField(String title, TextEditingController adressTextController,
      {int lines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              maxLines: lines,
              controller: adressTextController,
              decoration:
                  MyTextInputFieldStyles.getWhiteSpacePrimaryBorder(title))
        ],
      ),
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: () async {
        if (titleController.text != "") {
          _addDevelopmentIdea();
        } else {
          openErrorSnackBar(context,
              MyLocalization().addDevelopmentIdeasPageNotificationNoTitle.tr);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [MyColors.primaryColor, MyColors.thirdColor])),
        child: Text(
          MyLocalization().addDevelopmentIdeasPageSaveButton.tr,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _fieldWidget() {
    return Column(
      children: <Widget>[
        _entryField('asdadsa',
            titleController),
        _entryField(MyLocalization().addDevelopmentIdeasPageDescriptionLable.tr,
            descriptionController,
            lines: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            MyLocalization().addDevelopmentIdeasPageTitle.tr,
            style: GoogleFonts.racingSansOne(color: MyColors.primaryColor),
          ),
          backgroundColor: Colors.white,
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
        body: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 15),
                      _fieldWidget(),
                      const SizedBox(height: 20),
                      _saveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _addDevelopmentIdea() async {
    CollectionReference developmentIdea = FirebaseFirestore.instance
        .collection(FirebaseCollection().developmentIdeas);

    developmentIdea.add({
      'description': descriptionController.text,
      'title': titleController.text,
      'state': "offen",
      'createdById': currentUserInformations.id,
      'createdDateTime': DateTime.now(),
      'personLiked': []
    }).then((value) async {
      openSuccsessSnackBar(
        context,
        MyLocalization()
            .addDevelopmentIdeasPageNotificationThankYouForEntering
            .tr,
      );
      Navigator.pop(context);
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().users)
          .where('roleAdmin', isEqualTo: true)
          .get()
          .then((adminUsers) {
        for (var adminUser in adminUsers.docs) {
          sendPushMessage(adminUser.get('fcmtoken'), "Neue Entwicklungsidee",
              titleController.text);
          sendFeedbackMailToDeveloper(
              "Neue Entwicklungsidee von ${currentUserInformations.name}: ${titleController.text}",
              descriptionController.text,
              context);
        }
      });
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().addDevelopmentIdeasPageNotificationFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add developmentIdea: $error");
      }
    });
  }
}
