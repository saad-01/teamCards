
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class EventCardHome extends StatefulWidget {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String image;
  final GeoPoint location;

  const EventCardHome({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.image,
    required this.location,
  }) : super(key: key);

  @override
  State<EventCardHome> createState() => _EventCardHomeState();
}

class _EventCardHomeState extends State<EventCardHome> {

  @override
  void initState() {
    super.initState();
    _getData();
  }

  late GeoData _locationAdress;

  bool _loading = true;

  _getData() async {
    try {
      _locationAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
      );

      setState(() {
        _loading = false;
      });
    } catch(_) {}
  }

  @override
  Widget build(BuildContext context) {

    // if (_loading) {
    //   return const Loading();
    // }
    return Container(
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CircleAvatar(
                  backgroundColor: MyColors.kWhiteColor,
                  backgroundImage: widget.image.isNotEmpty ? NetworkImage(
                    widget.image,
                  ) : null,
                  radius: 25,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: MyColors.kBlackColor),
                      ),
                      Text(
                        widget.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 30,
              ),
              Text(
                "${MyLocalization().location.tr}:",
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  _loading ? "Unable to load" : _locationAdress.address,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 30,
              ),
              Text(
                '${MyLocalization().date.tr}:\t\t\t',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.date,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(
                width: 60,
              ),
              Text(
                '${MyLocalization().time.tr}:\t\t\t',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.time,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}