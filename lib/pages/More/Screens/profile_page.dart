import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.profileName,
    required this.profileImage,
    required this.profileLevel,
    required this.profilePoints,
  }) : super(key: key);
  final String profileName;
  final String profileImage;
  final num profileLevel;
  final num profilePoints;
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    String imgUrl = widget.profileImage;

    return Stack(
      children: <Widget>[
        Container(
          color: MyColors.primaryColor,
        ),
        Image.network(
          imgUrl,
          fit: BoxFit.fill,
        ),
        BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 6.0,
              sigmaY: 6.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.primaryColor.withOpacity(0.9),
                //borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              ),
            )),
        Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(widget.profileName),
              centerTitle: false,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: height / 12,
                    ),
                    CircleAvatar(
                      radius: width < height ? width / 4 : height / 4,
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                    SizedBox(
                      height: height / 25.0,
                    ),
                    Text(
                      widget.profileName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width / 15,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: height / 30, left: width / 8, right: width / 8),
                      child: Text(
                        getCurrentUserLevelDescription(widget.profileLevel),
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: width / 25,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      height: height / 30,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(MyColors.grey01)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Level",
                                      style: TextStyle(
                                        color: Color(MyColors.subheading),
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      widget.profileLevel.toString(),
                                      style: TextStyle(
                                        color: Color(MyColors.subheading),
                                        fontSize: 35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color(MyColors.bg03),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      MyLocalization()
                                          .profilePagePointsLable
                                          .tr,
                                      style: TextStyle(
                                        color: Color(MyColors.subheading),
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      widget.profilePoints.toString(),
                                      style: TextStyle(
                                        color: Color(MyColors.subheading),
                                        fontSize: 35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
            ))
      ],
    );
  }

  Widget rowFacts(num count, String type) => Expanded(
          child: Column(
        children: <Widget>[
          Text(
            '$count',
            style: const TextStyle(color: Colors.white),
          ),
          Text(type,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal))
        ],
      ));
}
