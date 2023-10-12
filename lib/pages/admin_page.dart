import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String username = "TestUser";
  String email = "@kevindroll.de";
  String password = "1234567890";
  bool _loading = false;
  TextEditingController userIdController = TextEditingController();
  createNewUser(int nid) async {
    bool successfull = false;
    try {
      successfull = true;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: nid.toString() + email, password: password)
          .then((value) async {
        // await user?.updateDisplayName(username);
        // await user?.updateEmail(email);
        // await FirebaseAuth.instance.setLanguageCode("de");
        CollectionReference users =
            FirebaseFirestore.instance.collection(FirebaseCollection().users);
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        await users.doc(value.user!.uid).set({
          'email': nid.toString() + email,
          'fcmtoken': "",
          'id': value.user!.uid,
          'image': placeHolderProfileImage,
          'lastLogin': DateTime.now(),
          'registerDate': DateTime.now(),
          'name': username,
          'pushNotification': true,
          'level': 1,
          'points': 0,
          'onboardingScreenDone': false,
          'roleAdmin': false,
          'platform': userPlatform(),
          'version': packageInfo.version
        }).catchError((error) {
          openErrorSnackBar(
            context,
            "Benutzer erstellen nicht möglich",
          );
          if (kDebugMode) {
            print("Failed to add user: $error");
          }
        }).then((newValue) async {
          await FirebaseFirestore.instance
              .collection(FirebaseCollection().groups)
              .doc("TMHDrH6a50eUgluhOzsh")
              .update({
            'member': FieldValue.arrayUnion([value.user!.uid])
          }).then((newervalue) async {
            await FirebaseFirestore.instance
                .collection(FirebaseCollection().rides)
                .add({
              'description': "Import Test",
              'freeSeats': 2,
              'offeredSeats': 2,
              'createdById': value.user!.uid,
              'eventId': "tPoeOxLYCfnNNtMoDbAQ",
              'passenger': [],
              'departureTime': DateTime.now().add(const Duration(days: 15)),
              'location': const GeoPoint(48.6824642, 8.1500317),
            });
          });
          setState(() {
            _loading = true;
          });
        }).whenComplete(() async {
          openSuccsessSnackBar(
            context,
            "Benutzer wurde erstellt",
          );
          setState(() {
            _loading = false;
          });
        });
      });
    } on FirebaseAuthException catch (e) {
      successfull = false;
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
        openErrorSnackBar(context, "Passwort mind. 6 Zeichen");
      } else if (e.code == 'email-already-in-use') {
        openErrorSnackBar(context, "Email bereits registriert");
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      } else {
        openErrorSnackBar(context, "Unerwarteter Fehler aufgetreten");
        if (kDebugMode) {
          print(e.code);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (kDebugMode) {
      print("IsSuccessfull: $successfull");
    }
    if (successfull) {}
  }

  deleteTestUser(int nid) async {
    String email = "@kevindroll.de";
    String password = "1234567890";
    if (kDebugMode) {
      print(nid.toString() + email);
    }
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: nid.toString() + email, password: password)
        .then((value) async {
      await FirebaseFirestore.instance
          .collection(FirebaseCollection().users)
          .doc(value.user!.uid)
          .update({'name': 'Gelöscht'}).then((userValue) async {
        await FirebaseAuth.instance.currentUser!.delete();
      }).then((value) {
        if (kDebugMode) {
          print("$nid$email Firestore wurde aktualisiert");
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print(error.toString());
        }
      });
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    }).then((value) {
      if (kDebugMode) {
        print("$nid$email Nutzer wurde entfernt");
      }
    });
  }

  deleteFirebaseCollectionTestUser() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().users)
        .where('name', isEqualTo: 'Gelöscht')
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().users)
            .doc(doc.id)
            .delete();
      }
    });
  }

  pushToGroupsWith1Member() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        if (doc['member'].length <= 1) {
          await FirebaseFirestore.instance
              .collection(FirebaseCollection().users)
              .doc(doc['createdById'])
              .get()
              .then((value) async {
            sendPushMessage(
                value['fcmtoken'],
                value['name'] +
                    ", hast Du deine Gruppe " +
                    doc['name'] +
                    " vergessen?",
                "Lade weitere Personen in Deine Gruppe ein und teilt euch eure Spritkosten");

            if (kDebugMode) {
              print(value.id);
            }
          });
          if (kDebugMode) {
            print(doc.id);
          }
        }
      }
    });
  }

  deleteFirebaseCollectionTestRide() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().chatMessages)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().chatRoom)
            .doc(doc['assignedChatRoomId'])
            .get()
            .then((valueUser) async {
          if (!valueUser.exists) {
            await FirebaseFirestore.instance
                .collection(FirebaseCollection().chatMessages)
                .doc(doc.id)
                .delete();
          }
        });
      }
    }).whenComplete(() {
      if (kDebugMode) {
        print("Completed");
      }
    });
  }

  updateUsersAddKM() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().users)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().users)
            .doc(doc.id)
            .update({'costPerKM': 0.30});
      }
    });
  }

  updateRideAddDistance() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().events)
            .doc(doc['eventId'])
            .get()
            .then((event) async {
          if (event.exists) {
            await FirebaseFirestore.instance
                .collection(FirebaseCollection().rides)
                .doc(doc.id)
                .update({
              'distance': await getDistance(doc['location'], event['location'])
            });
          }
        });
      }
    });
  }

  updateRides() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().rides)
            .doc(doc.id)
            .update({
          'isFlexibleTime': false,
          'flexibleTime': {'previous': 0, 'later': 0}
        });
      }
    });
  }

  updateMessages() async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().chatMessages)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().chatMessages)
            .doc(doc.id)
            .update({
          'readDateTime': DateTime.now(),
        });
      }
    });
  }

  deleteAllActionsFromUser(String userId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().rides)
        .where('createdById', isEqualTo: userId)
        .get()
        .then((rides) async {
      for (var ride in rides.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().rides)
            .doc(ride.id)
            .delete();
      }
    }).whenComplete(
            () => openSuccsessSnackBar(context, "Alle Fahrten entfernt"));
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().events)
        .where('createdById', isEqualTo: userId)
        .get()
        .then((events) async {
      for (var event in events.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().events)
            .doc(event.id)
            .delete();
      }
    }).whenComplete(
            () => openSuccsessSnackBar(context, "Alle Termine entfernt"));
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().historyPoints)
        .where('userId', isEqualTo: userId)
        .get()
        .then((historyPoints) async {
      for (var historyPoint in historyPoints.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().historyPoints)
            .doc(historyPoint.id)
            .delete();
      }
    }).whenComplete(
            () => openSuccsessSnackBar(context, "Alle Historien entfernt"));

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().chatMessages)
        .where('senderID', isEqualTo: userId)
        .get()
        .then((chatMessages) async {
      for (var chatMessage in chatMessages.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().chatMessages)
            .doc(chatMessage.id)
            .delete();
      }
    }).whenComplete(
            () => openSuccsessSnackBar(context, "Alle Nachrichten entfernt"));
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().chatRoom)
        .where('createdByUserId', isEqualTo: userId)
        .get()
        .then((chatRoom) async {
      for (var chatRoom in chatRoom.docs) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().chatRoom)
            .doc(chatRoom.id)
            .delete();
      }
    }).whenComplete(
            () => openSuccsessSnackBar(context, "Alle ChatRooms entfernt"));
  }

  @override
  void initState() {
    userIdController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (_loading) {
      return const Loading();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Admin",
          style: GoogleFonts.racingSansOne(
              fontSize: 36, color: MyColors.primaryColor),
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
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    onTap: () async {
                      for (int i = 1000; i < 1100; i++) {
                        await createNewUser(i);
                      }
                    },
                    title: const Text("Benutzer importieren"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.remove),
                    onTap: () async {
                      for (int i = 1; i < 69; i++) {
                        await deleteTestUser(i);
                      }
                    },
                    title: const Text("Benutzer entfernen"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    onTap: () async {
                      //await deleteFirebaseCollectionTestUser();
                      await deleteFirebaseCollectionTestRide();
                    },
                    title: const Text("Firestore aufräumen"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    onTap: () async {
                      await pushToGroupsWith1Member();
                    },
                    title: const Text("Push an Gruppen mit 1 Person"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timelapse),
                    onTap: () async {
                      await updateRides();
                    },
                    title: const Text("Fahrten aktualisieren"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat),
                    onTap: () async {
                      await updateMessages();
                    },
                    title: const Text("Nachrichten gelesenzeit hinzufügen"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    onTap: () async {
                      userIdController.text = "";
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Nutzer ID'),
                              content: TextField(
                                controller: userIdController,
                                decoration: const InputDecoration(
                                    hintText: "Nutzer ID eingeben"),
                              ),
                              actions: [
                                MaterialButton(
                                  child: const Text('Löschen'),
                                  onPressed: () async {
                                    await deleteAllActionsFromUser(
                                        userIdController.text);

                                    Navigator.of(context).pop();
                                  },
                                ),
                                MaterialButton(
                                  child: const Text('Abbrechen'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    },
                    title: const Text("Aktivitäten von Nutzer löschen"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.car_crash),
                    onTap: () async {
                      await updateUsersAddKM();
                    },
                    title: const Text("KM zu User hinzufügen"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.car_crash),
                    onTap: () async {
                      await updateRideAddDistance();
                    },
                    title: const Text("KM zu Fahrten hinzufügen"),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
