import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';

import '../../../constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Home/Widgets/appbar_widget.dart';
import '../Widgets/chat_tile_widget.dart';
import 'chat_details.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _fireStore = FirebaseFirestore.instance;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _drivers;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _groups;
  Stream<QuerySnapshot<Map<String, dynamic>>> personalData = FirebaseFirestore
      .instance
      .collection(FirebaseCollection().chatMessages)
      .where('recipientID', isEqualTo: currentUserInformations.id)
      .where('readDateTime', isNull: true)
      .snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> groupData = FirebaseFirestore
      .instance
      .collection(FirebaseCollection().chatMessages)
      .where('assignedChatRoomId',
          whereIn: currentUserInformations.memberGroups)
      .where('senderID', isNotEqualTo: currentUserInformations.id)
      .where('readDateTime', isNull: true)
      .snapshots();

  bool _loading = true;
  bool showAds = true;
  late final BannerAd? myBanner1;

  void getData() async {
    if (!kIsWeb) {
      myBanner1 = BannerAd(
        adUnitId: (Platform.isAndroid)
            ? googleAdMobAndroidBannerId
            : googleAdMobIOSBannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
      String role = await MyPref.getRole();
      if (role == 'free') {
        showAds = true;
        await myBanner1!.load();
      } else {
        showAds = false;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> makeRead(QuerySnapshot<Map<String, dynamic>> value) async {
    if (value.docs.isNotEmpty) {
      for (var chatMessage in value.docs) {
        await _fireStore
            .collection(FirebaseCollection().chatMessages)
            .doc(chatMessage.id)
            .update({'readDateTime': DateTime.now()});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _drivers = _fireStore
        .collection(FirebaseCollection().chatRoom)
        .where('contacts', arrayContains: currentUserInformations.id)
        .snapshots();
    _groups = _fireStore
        .collection(FirebaseCollection().groups)
        .where('member', arrayContains: currentUserInformations.id)
        .snapshots();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    print(currentUserInformations.id);

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
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
                  AppBarWidget(
                      textt: MyLocalization().messages.tr,
                      imageAddress: 'assets/home/languageGlobe.png',
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LanguageSelectPage(),
                        ));
                      }),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  showAds
                      ? Visibility(
                          visible: !kIsWeb && !_loading,
                          child: SizedBox(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: AdWidget(ad: myBanner1!)),
                        )
                      : SizedBox(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: MyColors.kGreenColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        StreamBuilder(
                            stream: personalData,
                            builder: (context, personalN) {
                              if (personalN.hasData) {
                                return Tab(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Badge(
                                      alignment: Alignment.topRight,
                                      label: Text(
                                          (personalN.data!.size).toString()),
                                      isLabelVisible: personalN.data!.size != 0,
                                      backgroundColor: Colors.blue,
                                      child: Center(
                                        child: Text(
                                          MyLocalization().drivers.tr,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Tab(text: MyLocalization().drivers.tr);
                            }),
                        StreamBuilder(
                            stream: groupData,
                            builder: (context, group) {
                              if (group.hasData) {
                                return Tab(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Badge(
                                      alignment: Alignment.topRight,
                                      label:
                                          Text((group.data!.size).toString()),
                                      isLabelVisible: group.data!.size != 0,
                                      backgroundColor: Colors.blue,
                                      child: Center(
                                        child: Text(
                                          MyLocalization().group.tr,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Tab(text: MyLocalization().group.tr);
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        StreamBuilder(
                          stream: _drivers,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Loading();
                            }
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/chat/chatpagelogo.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        MyLocalization().noMessages.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            MyLocalization().messageTip.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/chat/chatpagelogo.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        MyLocalization().noMessages.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            MyLocalization().messageTip.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }
                            var data = snapshot.data!.docs.where((element) {
                              if (element.data().containsKey('delete')) {
                                if (element
                                    .data()['delete']
                                    .contains(currentUserInformations.id)) {
                                  return false;
                                }
                              }
                              return true;
                            });
                            if (data.isEmpty) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/chat/chatpagelogo.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        MyLocalization().noMessages.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            MyLocalization().messageTip.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView(
                              children: snapshot.data!.docs.map(
                                (document) {
                                  if (!document.exists) {
                                    return Center(
                                      child: Text(MyLocalization()
                                          .messagesPageNoMessages
                                          .tr),
                                    );
                                  }

                                  Timestamp lastEditDateTime =
                                      document['lastEditDateTime'];
                                  String rideId = document['assignedRideId'];
                                  List contacts = document['contacts'];
                                  String chatroomId = document.id;
                                  bool senderIsMe = false;

                                  if (currentUserInformations.id ==
                                      document['createdByUserId']) {
                                    senderIsMe = true;
                                  }
                                  bool isUnreadedFromRecipient =
                                      document['isUnreadFromRecipient'];
                                  bool isUnreadedFromSender =
                                      document['isUnreadFromSender'];

                                  bool isUnreaded = senderIsMe
                                      ? isUnreadedFromSender
                                      : isUnreadedFromRecipient;

                                  if (kDebugMode) {
                                    print("DocumentID: ${document.id}");
                                    print("SenderMe: $senderIsMe");
                                    print(
                                        "SenderUnread: $isUnreadedFromSender");
                                    print(
                                        "RecipientUnread: $isUnreadedFromRecipient");
                                    print("SummaryUnread: $isUnreaded");
                                    print("CONTACTS: $contacts");
                                    print(contacts.where((element) =>
                                        element != currentUserInformations.id));
                                  }

                                  List deleted = [];
                                  try {
                                    deleted = document['delete'];
                                  } catch (_) {}

                                  return Visibility(
                                    visible: !deleted
                                        .contains(currentUserInformations.id),
                                    child: FutureBuilder(
                                      future: _fireStore
                                          .collection(
                                              FirebaseCollection().users)
                                          .doc(contacts
                                              .where((element) =>
                                                  element !=
                                                  currentUserInformations.id)
                                              .first)
                                          .get(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              userShot) {
                                        if (!userShot.hasData) {
                                          return const Loading();
                                        }

                                        String profileURL =
                                            userShot.data!.get('image');
                                        String otherUserId = userShot.data!.id;
                                        String otherUserName =
                                            userShot.data!.get('name');
                                        String lastOnline = formatterDDMMYYYHHMM
                                            .format(userShot.data!
                                                .get('lastLogin')
                                                .toDate())
                                            .toString();
                                        return FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection(
                                                    FirebaseCollection().rides)
                                                .doc(rideId)
                                                .get(),
                                            builder: (context, rideData) {
                                              if (rideData.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox();
                                              } else if (rideData.hasData) {
                                                String eventId = rideData.data!
                                                    .get('eventId');
                                                return FutureBuilder(
                                                    future: FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            FirebaseCollection()
                                                                .events)
                                                        .doc(eventId)
                                                        .get(),
                                                    builder:
                                                        (context, eventShot) {
                                                      if (eventShot.hasData) {
                                                        String eventName =
                                                            eventShot.data!
                                                                .get('title');
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ChatDetailScreen(
                                                                  otherUserId:
                                                                      otherUserId,
                                                                  otherName:
                                                                      otherUserName,
                                                                  otherImage:
                                                                      profileURL,
                                                                  chatRoomId:
                                                                      chatroomId,
                                                                  lastOnline:
                                                                      lastOnline,
                                                                  isSenderMe:
                                                                      senderIsMe,
                                                                  drivenKm:
                                                                      eventName,
                                                                ),
                                                              ),
                                                            );
                                                            if (senderIsMe) {
                                                              await _fireStore
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatRoom)
                                                                  .doc(
                                                                      chatroomId)
                                                                  .update({
                                                                'isUnreadFromSender':
                                                                    false
                                                              });
                                                              await _fireStore
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatMessages)
                                                                  .where(
                                                                      'assignedChatRoomId',
                                                                      isEqualTo:
                                                                          chatroomId)
                                                                  .where(
                                                                      'recipientID',
                                                                      isEqualTo:
                                                                          currentUserInformations
                                                                              .id)
                                                                  .where(
                                                                      'readDateTime',
                                                                      isNull:
                                                                          true)
                                                                  .get()
                                                                  .then(
                                                                      (value) async {
                                                                if (value.docs
                                                                    .isNotEmpty) {
                                                                  for (var chatMessage
                                                                      in value
                                                                          .docs) {
                                                                    await _fireStore
                                                                        .collection(FirebaseCollection()
                                                                            .chatMessages)
                                                                        .doc(chatMessage
                                                                            .id)
                                                                        .update({
                                                                      'readDateTime':
                                                                          DateTime
                                                                              .now()
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                            } else {
                                                              await _fireStore
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatRoom)
                                                                  .doc(
                                                                      chatroomId)
                                                                  .update({
                                                                'isUnreadFromRecipient':
                                                                    false
                                                              });
                                                              await _fireStore
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatMessages)
                                                                  .where(
                                                                      'assignedChatRoomId',
                                                                      isEqualTo:
                                                                          chatroomId)
                                                                  .where(
                                                                      'recipientID',
                                                                      isEqualTo:
                                                                          currentUserInformations
                                                                              .id)
                                                                  .where(
                                                                      'readDateTime',
                                                                      isNull:
                                                                          true)
                                                                  .get()
                                                                  .then(
                                                                      (value) async {
                                                                if (value.docs
                                                                    .isNotEmpty) {
                                                                  for (var chatMessage
                                                                      in value
                                                                          .docs) {
                                                                    await _fireStore
                                                                        .collection(FirebaseCollection()
                                                                            .chatMessages)
                                                                        .doc(chatMessage
                                                                            .id)
                                                                        .update({
                                                                      'readDateTime':
                                                                          DateTime
                                                                              .now()
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                            }
                                                          },
                                                          child: Dismissible(
                                                            background:
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .redAccent,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                              child: const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            key:
                                                                Key(chatroomId),
                                                            onDismissed:
                                                                (val) async {
                                                              final doc = FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatRoom)
                                                                  .doc(
                                                                      chatroomId);
                                                              if (deleted
                                                                  .isNotEmpty) {
                                                                await doc
                                                                    .delete();
                                                                return;
                                                              }
                                                              var numbers = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      FirebaseCollection()
                                                                          .chatMessages)
                                                                  .where(
                                                                      'assignedChatRoomId',
                                                                      isEqualTo:
                                                                          chatroomId)
                                                                  .where(
                                                                      'recipientID',
                                                                      isEqualTo:
                                                                          currentUserInformations
                                                                              .id)
                                                                  .where(
                                                                      'readDateTime',
                                                                      isNull:
                                                                          true)
                                                                  .get();
                                                              if (numbers
                                                                      .size !=
                                                                  0) {
                                                                for (var i
                                                                    in numbers
                                                                        .docs) {
                                                                  var msg = FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          FirebaseCollection()
                                                                              .chatMessages)
                                                                      .doc(
                                                                          i.id);
                                                                  await msg
                                                                      .update({
                                                                    "readDateTime":
                                                                        DateTime
                                                                            .now(),
                                                                  });
                                                                }
                                                              }
                                                              await doc.update({
                                                                "delete": [
                                                                  currentUserInformations
                                                                      .id
                                                                ],
                                                              });
                                                              setState(() {});
                                                            },
                                                            child:
                                                                ChatTileWidget(
                                                              name:
                                                                  otherUserName,
                                                              url: profileURL,
                                                              distance:
                                                                  eventName,
                                                              chatId:
                                                                  chatroomId,
                                                              time: formatterDDMMYYYHHMM
                                                                  .format(lastEditDateTime
                                                                      .toDate())
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return const SizedBox();
                                                      }
                                                    });
                                              } else {
                                                return const SizedBox();
                                              }
                                            });
                                      },
                                    ),
                                  );
                                },
                              ).toList(),
                            );
                          },
                        ),
                        StreamBuilder(
                          stream: _groups,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Loading();
                            }
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/chat/chatpagelogo.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        MyLocalization().groupPageNoGroups.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/chat/chatpagelogo.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        MyLocalization().groupPageNoGroups.tr,
                                        style: const TextStyle(
                                            color: MyColors.kBlackColor,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            MyLocalization().messageTip.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView(
                              children: snapshot.data!.docs.map(
                                (document) {
                                  String name = document['name'];
                                  String image = document['image'];
                                  String description = document['description'];
                                  String groupId = document.id;
                                  return GestureDetector(
                                    onTap: () async {
                                      await _fireStore
                                          .collection(
                                              FirebaseCollection().chatMessages)
                                          .where('assignedChatRoomId',
                                              isEqualTo: groupId)
                                          .where('recipientID', isEqualTo: '')
                                          .where('readDateTime', isNull: true)
                                          .get()
                                          .then((value) async {
                                        await makeRead(value).then((_) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatDetailScreen(
                                                otherUserId: '',
                                                otherName: name,
                                                otherImage: image,
                                                chatRoomId: groupId,
                                                lastOnline: '',
                                                isSenderMe: false,
                                                drivenKm: "",
                                                isGroup: true,
                                                description: description,
                                              ),
                                            ),
                                          );
                                        });
                                      });
                                    },
                                    child: ChatTileWidget(
                                      name: name,
                                      url: image,
                                      distance: "",
                                      chatId: groupId,
                                      time: '',
                                      group: true,
                                    ),
                                  );
                                },
                              ).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
