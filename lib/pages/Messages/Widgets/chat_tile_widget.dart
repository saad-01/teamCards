
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class ChatTileWidget extends StatelessWidget {
  const ChatTileWidget({
    super.key,
    required this.name,
    required this.url,
    required this.distance,
    required this.chatId,
    required this.time,
    this.role = '',
    this.group = false,
    this.onPressed,
    this.isAdmin = false,
    this.onMenuPress,
  });
  final String name;
  final String url;
  final String distance;
  final String chatId;
  final String time;
  final VoidCallback? onPressed;
  final String role;
  final bool group;
  final bool isAdmin;
  final VoidCallback? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:10.0),
      child: Card(
        child: ListTile(
          onTap: onPressed,
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(url)),
                borderRadius: BorderRadius.circular(15)),
          ),
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:  const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1),
          ),
          subtitle: distance.isNotEmpty ? Text(
            distance,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ) : null,
          trailing: Builder(
              builder: (context) {
                if(role.isEmpty) {
                  return StreamBuilder(
                      stream: !group ? FirebaseFirestore.instance.collection(FirebaseCollection().chatMessages)
                          .where('assignedChatRoomId', isEqualTo: chatId)
                          .where('recipientID', isEqualTo: currentUserInformations.id)
                          .where('readDateTime', isNull: true).snapshots()
                          : FirebaseFirestore.instance.collection(FirebaseCollection().chatMessages)
                          .where('assignedChatRoomId', isEqualTo: chatId)
                          .where('senderID', isNotEqualTo: currentUserInformations.id)
                          .where('readDateTime', isNull: true).snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Text(time);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            if(time.isNotEmpty) Text(time),
                            Builder(
                              builder: (context) {
                                if(snapshot.data!.size != 0) {
                                  return CircleAvatar(
                                    backgroundColor: MyColors.kGreenColor,
                                    radius: 10,
                                    // child: Text(widget.data['unRead'].toString(),style: TextStyle(color: bgColor,fontSize: 12),),
                                    child: Text(
                                      snapshot.data!.size.toString(),
                                      style:const TextStyle(
                                          color: MyColors.kWhiteColor, fontSize: 14),
                                    ),
                                  );
                                }else {return const SizedBox();}
                              },
                            ),
                          ],
                        );
                      }
                  );
                }else {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.22,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(role),
                        Visibility(
                          visible: isAdmin,
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              PopupMenuButton<int>(
                                onSelected: (value) {
                                  if(value == 1) {
                                    onMenuPress!.call();
                                  }
                                },
                                child: const Icon(Icons.more_vert),
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text(MyLocalization().deleteUser.tr),
                                    ),
                                  ];
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
          ),
        ),
      ),
    );
  }
}
