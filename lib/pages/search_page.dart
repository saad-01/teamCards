import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/More/Screens/profile_page.dart';

import 'Groups/Screens/group_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;
  final items = List.generate(1000, (index) => '$index');
  var filterOptions = [Filter.values.first];

  List searchResult = [];
  @override
  void initState() {
    super.initState();
    searchFromFirebase("");
  }

  void searchFromFirebase(String query) async {
    var result = await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .where('member', arrayContains: currentUserInformations.id)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    if (filterOptions.contains(Filter.groups)) {
      result = await FirebaseFirestore.instance
          .collection(FirebaseCollection().groups)
          .where('member', arrayContains: currentUserInformations.id)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
    } else if (filterOptions.contains(Filter.users)) {
      result = await FirebaseFirestore.instance
          .collection(FirebaseCollection().users)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
    }

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        height: double.infinity,
        transform: Matrix4.translationValues(xOffset, yOffset, 0)
          ..scale(scaleFactor)
          ..rotateY(isDrawerOpen ? -0.5 : 0),
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0)),
        child: Column(children: [
          buildAppBarBottom(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: MyTextInputFieldStyles.getWhiteSpacePrimaryBorder(
                  "Suchen..."),
              onChanged: (query) {
                searchFromFirebase(query);
              },
            ),
          ),
          Expanded(
            child: (filterOptions.isEmpty)
                ? const Text("Keine Filterung aktiviert")
                : ListView.builder(
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchResult[index]['image']),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(searchResult[index]['name']),
                        subtitle: (filterOptions.contains(Filter.groups))
                            ? Text(
                                "Mitglieder: ${searchResult[index]['member'].length}")
                            : Text(
                                "Registriert: ${formatterDDMMYYYHHMM.format(searchResult[index]['registerDate'].toDate()).toString()}"),
                        onTap: () {
                          (filterOptions.contains(Filter.groups))
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailsPage(
                                      group: searchResult[index]['name'],
                                      image: searchResult[index]['image'],
                                      createdDateTime: searchResult[index]
                                          ['createdDateTime'],
                                      description: searchResult[index]
                                          ['description'],
                                      groupId: searchResult[index]['id'],
                                    ),
                                  ),
                                )
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                      profileImage: searchResult[index]
                                          ['image'],
                                      profileLevel: searchResult[index]
                                          ['level'],
                                      profileName: searchResult[index]['name'],
                                      profilePoints: searchResult[index]
                                          ['points'],
                                    ),
                                  ),
                                );
                        },
                      );
                    },
                  ),
          ),
        ]));
  }

  PreferredSizeWidget buildAppBarBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: Filter.values.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                selectedColor: Colors.white,
                selected: filterOptions.contains(option),
                onSelected: (isSelected) {
                  setState(() {
                    if (filterOptions.isNotEmpty) {
                      if (!isSelected) {
                        filterOptions.remove(option);
                      }
                    } else {
                      if (isSelected) {
                        filterOptions.add(option);
                      }
                    }
                  });
                },
                label: Text(option.name),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Filter {
  static const Filter groups = Filter._('Gruppen', 1);
  static const Filter users = Filter._('Benutzer', 2);

  final String name;
  final int length;

  const Filter._(this.name, this.length);

  static const values = [
    Filter.groups,
    Filter.users,
  ];
}
