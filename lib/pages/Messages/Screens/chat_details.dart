import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../More/Widgets/message_profile_card.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.chatRoomId,
    required this.drivenKm,
    required this.isSenderMe,
    required this.lastOnline,
    required this.otherImage,
    required this.otherName,
    required this.otherUserId,
    this.isGroup = false,
    this.description = '',
  });

  final String drivenKm;
  final String otherName;
  final String otherUserId;
  final String otherImage;
  final String chatRoomId;
  final String lastOnline;
  final bool isSenderMe;

  final bool isGroup;
  final String description;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final messageController = TextEditingController();

  _sendMessage(TextEditingController messageText) async {
    if (messageText.text != "") {
      final textMessage = messageText.text;
      messageController.clear();
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().chatMessages)
          .add({
        'assignedChatRoomId': widget.chatRoomId,
        'message': textMessage,
        'recipientID': widget.otherUserId,
        'senderID': currentUserInformations.id,
        'sendDateTime': DateTime.now(),
        'readDateTime': null,
      });

      if (!widget.isGroup) {
        var doc = FirebaseFirestore.instance
            .collection(FirebaseCollection().chatRoom)
            .doc(widget.chatRoomId);
        var data = await doc.get();
        if (data.data()!.containsKey('delete')) {
          if (data.data()!['delete'].contains(widget.otherUserId)) {
            await doc.update({
              'delete': [],
            });
          }
        }
        if (widget.isSenderMe) {
          await doc.update({
            'isUnreadFromRecipient': true,
            'lastEditDateTime': DateTime.now()
          });
        } else {
          await FirebaseFirestore.instance
              .collection(FirebaseCollection().chatRoom)
              .doc(widget.chatRoomId)
              .update({
            'isUnreadFromSender': true,
            'lastEditDateTime': DateTime.now()
          });
        }
      }
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().users)
          .doc(widget.otherUserId)
          .get()
          .then((user) => sendPushMessage(
                  user['fcmtoken'], currentUserInformations.name, textMessage,
                  info: {
                    "type": "message",
                    "group": widget.isGroup,
                    "chatRoomId": widget.chatRoomId,
                    "drivenKM": widget.drivenKm,
                    "isSenderMe": widget.isSenderMe,
                    "otherName": widget.otherName,
                    "otherImage": widget.otherImage,
                    "otherUserId": widget.otherUserId,
                  }));
    }
  }

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _messages;

  _chatBubble(
    String message,
    String sendDateTime,
    bool isMe,
    bool isSameUser,
    DateTime? readDateTime,
  ) {
    print(message);
    print(readDateTime);
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          alignment: Alignment.topRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: MyColors.kGreenColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      sendDateTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    readDateTime == null
                        ? const Icon(Icons.done, color: Colors.white, size: 20)
                        : const Icon(Icons.done_all,
                            color: Colors.white, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  message,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sendDateTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _messages = FirebaseFirestore.instance
        .collection(FirebaseCollection().chatMessages)
        .where('assignedChatRoomId', isEqualTo: widget.chatRoomId)
        .orderBy('sendDateTime', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: MyColors.kBackGroundColor,
      body: Stack(
        children: [
          Image.asset(
            'assets/event/bg.png',
            height: 170,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarBackArrowWidget(
                textt: MyLocalization().chat.tr,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: _messages,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child:
                              Text(MyLocalization().messagesPageNoMessages.tr),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child:
                              Text(MyLocalization().messagesPageNoMessages.tr),
                        );
                      }
                      var items =
                          snapshot.data!.docs.toList().reversed.toList();
                      return Container(
                        margin: const EdgeInsets.only(right: 10, top: 150),
                        color: MyColors.kBackGroundColor,
                        child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DateTime? readDateTime =
                                (items[index]['readDateTime'] != null)
                                    ? items[index]['readDateTime'].toDate()
                                    : null;
                            final String message = items[index]['message'];
                            final bool isMe = items[index]['senderID'] ==
                                currentUserInformations.id;
                            final String sendDateTime = formatterDDMMYYYHHMM
                                .format(items[index]['sendDateTime'].toDate())
                                .toString();
                            bool isSameUser = false;

                            return _chatBubble(
                              message,
                              sendDateTime,
                              isMe,
                              isSameUser,
                              readDateTime,
                            );
                          },
                        ),
                      );
                    }),
              ),
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 1 - 120,
                        child: TextField(
                          controller: messageController,
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          cursorHeight: 20,
                          cursorColor: MyColors.kBlackColor,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            filled: true,
                            fillColor: MyColors.kWhiteColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: MyColors.kBlackColor, width: .3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: MyColors.kBlackColor, width: .3),
                            ),
                          ),
                        )),
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            color: const Color(0xff00B888),
                            borderRadius: BorderRadius.circular(28)),
                        child: IconButton(
                            onPressed: () async {
                              await _sendMessage(messageController);
                            },
                            icon: const Icon(
                              Icons.send,
                              size: 30,
                              color: MyColors.kWhiteColor,
                            )))
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: ProfileCardForMessage(
              url: widget.otherImage,
              title: widget.otherName,
              subtitle: widget.isGroup
                  ? widget.description
                  : widget.isSenderMe
                      ? MyLocalization().drivers.tr.replaceAll('s', '')
                      : MyLocalization().passenger.tr,
              thirdtitle: widget.drivenKm,
              editable: false,
              disctanceUrl: '',
            ),
          ),
        ],
      ),
    ));
  }
}
