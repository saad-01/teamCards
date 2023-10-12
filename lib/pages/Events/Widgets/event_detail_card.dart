import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class EventDetailCard extends StatefulWidget {
  const EventDetailCard({
    super.key,
    required this.date,
    required this.time,
    required this.location,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.groupName,
    required this.eventImage,
  });

  final String title;
  final String subtitle;
  final String date;
  final String time;
  final GeoPoint location;
  final String image;
  final String eventImage;
  final String groupName;

  @override
  State<EventDetailCard> createState() => _EventDetailCardState();
}

class _EventDetailCardState extends State<EventDetailCard> {
  GeoData? _locationAddress;

  getLocation() async {
    try {
      _locationAddress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      print(_locationAddress);
    } catch (e) {
      print('LOcation error');
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: MyColors.kWhiteColor,
                  backgroundImage: widget.image.isNotEmpty
                      ? NetworkImage(widget.image)
                      : null,
                  radius: 25,
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: MyColors.kGreenColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                height: 150,
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: MyColors.kGreenColor,
                    image: DecorationImage(
                        image: NetworkImage(
                          widget.eventImage.isNotEmpty
                              ? widget.eventImage
                              : widget.image,
                        ),
                        fit: BoxFit.fill),
                    borderRadius: BorderRadius.circular(14)),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: MyColors.kBlackColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Builder(builder: (context) {
                    if (_locationAddress == null) {
                      return const SizedBox();
                    }
                    return SizedBox(
                      width: 150,
                      child: Text(
                        _locationAddress!.address,
                        maxLines: 2,
                        softWrap: true,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${widget.date}\t\t\t${widget.time}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
