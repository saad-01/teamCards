import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Groups/Widgets/description_field_with_label.dart';

class DevelopmentIdeaDetailsPage extends StatefulWidget {
  final String title;
  final String description;
  final String developmentIdeaId;
  final Timestamp createdDateTime;
  final String createdById;
  final String state;

  const DevelopmentIdeaDetailsPage({
    Key? key,
    required this.description,
    required this.developmentIdeaId,
    required this.createdDateTime,
    required this.title,
    required this.createdById,
    required this.state,
  }) : super(key: key);

  @override
  State<DevelopmentIdeaDetailsPage> createState() =>
      _DevelopmentIdeaDetailsPageState();
}

TextEditingController titleController = TextEditingController();

TextEditingController descriptionController = TextEditingController();
TextEditingController versionController = TextEditingController();
bool _loading = true;
List _personLiked = [];

class _DevelopmentIdeaDetailsPageState
    extends State<DevelopmentIdeaDetailsPage> {
  getData() async {
    _personLiked = [];
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().developmentIdeas)
        .doc(widget.developmentIdeaId)
        .get()
        .then(
      (idea) {
        _personLiked = idea.get('personLiked');
      },
    );
    if (!kIsWeb) {
      await analytics.logEvent(
          name: "development_idea_details_opened",
          parameters: {'development_idea': widget.developmentIdeaId});
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateIdea() async {
    try {
      if (currentUserInformations.id == widget.createdById) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().developmentIdeas)
            .doc(widget.developmentIdeaId)
            .update({
          "description": _descriptionController.text,
          "state": state,
        });
      }
    } catch (_) {}
  }

  final _descriptionController = TextEditingController();
  late String state;

  @override
  void initState() {
    super.initState();
    getData();
    state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  AppBarBackArrowWidget(
                    textt: MyLocalization().ideas.tr,
                  ),
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MyColors.kWhiteColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                  backgroundColor: MyColors.kGreenColor,
                                  radius: 10,
                                  child: Text(
                                    _personLiked.length.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14)),
                            child: Image.asset(
                              'assets/settings/star.png',
                              fit: BoxFit.cover,
                            )),
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 50,
                          right: 20,
                        ),
                        child: Text(
                          MyLocalization().remarks.tr,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: MyColors.kBlackColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20,
                        ),
                        child: DescriptioFieldWithLabel(
                          controller: _descriptionController,
                          title: '',
                          onSaved: () async {
                            if (currentUserInformations.id ==
                                widget.createdById) {
                              await _updateIdea();
                            }
                          },
                          readOnly:
                              widget.createdById != currentUserInformations.id,
                          hintText: widget.description,
                          colour: Colors.black,
                          minline: 6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.only(left: 40),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButton<String>(
                          value: state,
                          items: [
                            DropdownMenuItem<String>(
                              value: "offen",
                              child: Text(
                                MyLocalization().open.tr,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "in Arbeit",
                              child: Text(
                                MyLocalization().working.tr,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "Umgesetzt",
                              child: Text(
                                MyLocalization().closed.tr,
                              ),
                            ),
                          ],
                          onChanged: currentUserInformations.roleAdmin
                              ? (value) async {
                                  setState(() {
                                    state = value!;
                                  });
                                  await _updateIdea();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_personLiked.contains(currentUserInformations.id)) {
                        await FirebaseFirestore.instance
                            .collection(FirebaseCollection().developmentIdeas)
                            .doc(widget.developmentIdeaId)
                            .update({
                          'personLiked': FieldValue.arrayRemove(
                              [currentUserInformations.id])
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection(FirebaseCollection().developmentIdeas)
                            .doc(widget.developmentIdeaId)
                            .update({
                          'personLiked': FieldValue.arrayUnion(
                              [currentUserInformations.id])
                        }).whenComplete(() async {
                          await FirebaseFirestore.instance
                              .collection(FirebaseCollection().users)
                              .doc(widget.createdById)
                              .get()
                              .then((value) {
                            sendPushMessage(
                                value['fcmtoken'],
                                "Deine Entwicklungsidee hat einen Like erhalten",
                                widget.title);
                          });
                        });
                      }
                      setState(() {
                        getData();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(40),
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          color:
                              _personLiked.contains(currentUserInformations.id)
                                  ? MyColors.kGreenColor
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(
                        Icons.thumb_up_alt,
                        color: MyColors.kWhiteColor,
                        size: 40,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
