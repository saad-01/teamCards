import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_add_page.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';

import '../../../constants.dart';
import 'group_page.dart';

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({super.key});

  @override
  GroupSettingsPageState createState() => GroupSettingsPageState();
}

class GroupSettingsPageState extends State<GroupSettingsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        currentUserInformations.image,
                      ),
                      backgroundColor: Colors.transparent,
                      radius: 60,
                    ),
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        color: Colors.transparent,
                        strokeWidth: 7,
                        value: 0,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 9,
                        color: MyColors.primaryColor,
                        value: currentUserInformations.points / levelUpValue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                currentUserInformations.name,
                style: GoogleFonts.quicksand(
                  fontSize: 25,
                  color: Color(MyColors.heading),
                  letterSpacing: 1,
                ),
              ),
              Text(
                "${MyLocalization().level.tr} ${currentUserInformations.level}",
                style: GoogleFonts.racingSansOne(
                  fontSize: 21,
                  color: MyColors.secondColor,
                  letterSpacing: 1,
                ),
              ),
              Text(
                getCurrentUserLevelDescription(currentUserInformations.level),
                style: GoogleFonts.racingSansOne(
                  fontSize: 18,
                  color: Color(MyColors.subheading),
                  letterSpacing: 1,
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 30),
                elevation: 10,
                child: Column(children: [
                  ListTile(
                    title: Text(
                      MyLocalization().groupSettingsPageItemMyGroups.tr,
                    ),
                    leading: Icon(
                      Icons.group,
                      color: MyColors.primaryColor,
                    ),
                    textColor: MyColors.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GroupsPage()),
                      );
                    },
                  ),
                  const Divider(thickness: 1),
                  ListTile(
                    title: Text(
                      MyLocalization().groupSettingsPageItemAddGroup.tr,
                    ),
                    leading: Icon(
                      Icons.group_add,
                      color: MyColors.primaryColor,
                    ),
                    textColor: MyColors.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GroupAddPage()),
                      );
                    },
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
