
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class CustomBottomAppBar extends StatefulWidget {
  const CustomBottomAppBar({
    super.key,
    required this.selectIndex,
    required this.onChange,
  });

  final int selectIndex;
  final Function(int) onChange;

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {

  Stream<QuerySnapshot<Map<String, dynamic>>> personalData = FirebaseFirestore.instance.collection(FirebaseCollection().chatMessages)
      .where('recipientID', isEqualTo: currentUserInformations.id)
      .where('readDateTime', isNull: true).snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> groupData = FirebaseFirestore.instance.collection(FirebaseCollection().chatMessages)
      .where('assignedChatRoomId', whereIn: currentUserInformations.memberGroups)
      .where('senderID', isNotEqualTo: currentUserInformations.id)
      .where('readDateTime', isNull: true).snapshots();

  @override
  Widget build(BuildContext context) {
    print(currentUserInformations.memberGroups);
    print(currentUserInformations.id);
    return SizedBox(
      height: 73,
      child: StreamBuilder(
        stream: personalData,
        builder: (context, personal) {
          if(personal.hasData) {
            return StreamBuilder(
              stream: groupData,
              builder: (context, group) {
                if(group.hasData) {
                  var personalN = personal.data!.size;
                  var groupN = group.data!.size;
                  return BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: widget.selectIndex,
                      onTap: widget.onChange,
                      selectedItemColor: MyColors.kGreenColor,
                      iconSize: 26,
                      unselectedFontSize: 13,
                      selectedFontSize: 15,
                      backgroundColor: MyColors.kWhiteColor,
                      items:  [
                        BottomNavigationBarItem(
                          icon:Image.asset('assets/home/home.png',width: 35,height: 35,fit: BoxFit.cover,),

                          //  icon:Icon(
                          //   Icons.home_outlined,
                          // ),
                          label: MyLocalization().home.tr,
                        ),
                        BottomNavigationBarItem(
                          icon:Image.asset('assets/home/events.png',width: 35,height: 35,fit: BoxFit.cover,),

                          //  icon:Icon(Icons.calendar_month_rounded),
                          label: MyLocalization().event.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: Badge(
                            label: Text((personalN + groupN).toString()),
                            isLabelVisible: (personalN + groupN) != 0,
                            backgroundColor: MyColors.kGreenColor,
                            child: Image.asset(
                              'assets/home/chaticon.png',width: 35,height: 35,fit: BoxFit.cover,),
                          ),
                          label: MyLocalization().messages.tr,
                        ),
                        BottomNavigationBarItem(
                          // icon: Icon(Icons.more_horiz_sharp),
                          icon: Image.asset('assets/home/more.png',width: 35,height: 35,fit: BoxFit.cover,),

                          label: MyLocalization().more.tr,
                        ),
                      ]);
                }
                return const SizedBox();
              }
            );
          }
          return const SizedBox();
        }
      ),
    );
  }
}