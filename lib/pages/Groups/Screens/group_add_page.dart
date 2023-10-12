import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/description_field_with_label.dart';
import '../Widgets/edit_profile_image_widget.dart';

class GroupAddPage extends StatefulWidget {
  const GroupAddPage({
    Key? key,
    this.edit = false,
    this.groupId = '',
    this.admins = const [],
    this.members = const [],
  }) : super(key: key);

  final bool edit;
  final String groupId;
  final List admins;
  final List members;

  @override
  GroupAddPageState createState() => GroupAddPageState();
}

class GroupAddPageState extends State<GroupAddPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  Uint8List byteList = Uint8List(0);
  bool _loading = true;
  bool pickedImage = false;
  String description = "";
  String name = "";
  String image = "";
  List admins = [];
  List members = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    await getUserData();

    if(widget.edit) {
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().groups)
          .doc(widget.groupId)
          .get()
          .then((group) {
        description = group.get('description');
        image = group.get('image');
        name = group.get('name');
        nameController.text = name;
        descriptionController.text = description;
        admins = widget.admins;
        members = widget.members;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  _updateGroup() async {
    setState(() {
      _loading = true;
    });
    String groupImage = image;

    FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .doc(widget.groupId)
        .update({
      'description': descriptionController.text,
      'name': nameController.text,
      'image': groupImage,
      'lastModifiedDateTime': DateTime.now(),
      "groupAdmin": admins,
    }).then((value) async {
      if (pickedImage) {
        groupImage =
        await uploadImageFirestorage("groups", widget.groupId, byteList);
        FirebaseFirestore.instance
            .collection(FirebaseCollection().groups)
            .doc(widget.groupId)
            .update({"image": groupImage});
      }
      setState(() {
        _loading = false;
      });
    }).then((val) {
      FirebaseFirestore.instance
          .collection(FirebaseCollection().events)
          .where('groupId', isEqualTo: widget.groupId)
          .get()
          .then((value) {
        for (var event in value.docs) {
          FirebaseFirestore.instance
              .collection(FirebaseCollection().events)
              .doc(event.id)
              .update({'group': nameController.text});
        }
      }).then((val) {
        Navigator.pop(context);
        openSuccsessSnackBar(
          context,
          MyLocalization().groupEditPageNotificationUpdateGroupSuccessfull.tr,
        );
      });
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().groupEditPageNotificationUpdateGroupFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add group: $error");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // final height = MediaQuery.of(context).size.height;

    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
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
                    textt: widget.edit ? MyLocalization().groupEditPageTitle.tr : MyLocalization().addGroup.tr,
                    pencileUrl: 'assets/settings/pencile.png',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                      margin:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                            withData: true,
                          );

                          if (result != null) {
                            PlatformFile file = result.files.first;
                            byteList = file.bytes!;
                            pickedImage = true;
                            setState(() {});
                          }
                        },
                        child:
                        Visibility(
                          visible: !kIsWeb,
                          child: EditProfileImageWidget(
                            hasImage: pickedImage,
                            asset: true,
                            image: byteList.isNotEmpty ? Image.memory(Uint8List.fromList(byteList)) : null,
                              url: 'assets/home/profile.jpg'),
                        ),
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DescriptioFieldWithLabel(
                              controller: nameController,
                                title: MyLocalization().name.tr,
                                hintText: MyLocalization().group.tr,
                                colour: Colors.black,
                                minline: 1),
                            DescriptioFieldWithLabel(
                              controller: descriptionController,
                                title: MyLocalization().description.tr,
                                hintText: MyLocalization().description.tr,
                                colour: Colors.black,
                                minline: 6),
                            Builder(
                              builder: (context) {
                                if(widget.edit) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Text(
                                          MyLocalization().groupDetailsPageAdminCardTitle.tr,
                                          style: const TextStyle(
                                              color: Colors.black,fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.4,
                                                  width: MediaQuery.of(context).size.width * 0.5,
                                                  child: AlertDialog(
                                                    title: Text(
                                                      MyLocalization().groupDetailsPageMemberCardTitle.tr,
                                                    ),
                                                    content: SizedBox(
                                                      height: MediaQuery.of(context).size.height * 0.3,
                                                      width: MediaQuery.of(context).size.width * 0.45,
                                                      child: FutureBuilder(
                                                        future: FirebaseFirestore.instance.collection
                                                          (FirebaseCollection().users).where('id', whereIn: members).get(),
                                                        builder: (context, snapshot) {
                                                          if(snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                            List data = snapshot.data!.docs;
                                                            return ListView.builder(
                                                              itemCount: data.length,
                                                              itemBuilder: (context, i) {
                                                                return GestureDetector(
                                                                  onTap: () async {
                                                                    if(currentUserInformations.id
                                                                        != data[i]['id']) {
                                                                      if(admins.contains(data[i]['id'])) {
                                                                        setState(() {
                                                                          admins.remove(data[i]['id']);
                                                                        });
                                                                        Navigator.pop(context);
                                                                        await _updateGroup();
                                                                      }else {
                                                                        setState(() {
                                                                          admins.add(data[i]['id']);
                                                                          admins.toSet();
                                                                        });
                                                                        Navigator.pop(context);
                                                                        await _updateGroup();
                                                                      }
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    margin: const EdgeInsets.only(right: 20, bottom: 10),
                                                                    padding: const EdgeInsets.all(10),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        border: Border.all(
                                                                            color: admins.contains(data[i]['id'])
                                                                                ? MyColors.kGreenColor
                                                                                : Colors.transparent
                                                                        )
                                                                    ),
                                                                    child: Row(
                                                                      children: <Widget>[
                                                                        CircleAvatar(
                                                                          radius: 20,
                                                                          backgroundImage: NetworkImage(data[i]['image']),
                                                                        ),
                                                                        const SizedBox(width: 10),
                                                                        Text(
                                                                          data[i]['name'],
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 15,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            return const SizedBox();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10),
                                            height: MediaQuery.of(context).size.height * 0.12,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(width: 0.5, color: Colors.black),
                                            ),
                                            child: FutureBuilder(
                                                future: FirebaseFirestore.instance.collection
                                                  (FirebaseCollection().users).where('id', whereIn: admins).get(),
                                                builder: (context, snapshot) {
                                                  if(snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                    List data = snapshot.data!.docs;
                                                    return ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: data.length,
                                                      itemBuilder: (context, i) {
                                                        return Container(
                                                          margin: const EdgeInsets.only(right: 20),
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              CircleAvatar(
                                                                radius: 20,
                                                                backgroundImage: NetworkImage(data[i]['image']),
                                                              ),
                                                              Text(
                                                                data[i]['name'],
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                }
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 40),
                        child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isNotEmpty) {
                                if(widget.edit) {
                                  await _updateGroup();
                                } else {
                                  await _addGroup();
                                }
                              } else {
                                openErrorSnackBar(context,
                                    MyLocalization().addGroupPageNotificationNameNotNull.tr);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.kGreenColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: MyColors.kBlackColor, width: .2)),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                                minimumSize: const Size(double.infinity, 52)),
                            child: Text(MyLocalization().save.tr)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

  }

  _addGroup() async {
    setState(() {
      _loading = true;
    });
    String groupImage = placeHolderGroupsImage;

    CollectionReference groups =
        FirebaseFirestore.instance.collection(FirebaseCollection().groups);

    groups.add({
      'description': descriptionController.text,
      'createdById': currentUserInformations.id,
      'groupAdmin': [currentUserInformations.id],
      'member': [currentUserInformations.id],
      'name': nameController.text,
      'image': groupImage,
      'createdDateTime': DateTime.now(),
    }).then((value) async {
      if (pickedImage) {
        groupImage = await uploadImageFirestorage("groups", value.id, byteList);
        groups.doc(value.id).update({"image": groupImage});
      }

      groups.doc(value.id).update({'id': value.id});
      setState(() {
        _loading = false;
      });
    }).then((val) async {
      Navigator.pop(context);
      openSuccsessSnackBar(
        context,
        MyLocalization().addGroupPageNotificationGroupAddedSuccessfull.tr,
      );
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().addGroupPageNotificationGroupAddedFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add group: $error");
      }
    });
  }
}
