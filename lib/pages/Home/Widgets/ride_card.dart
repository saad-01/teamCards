import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class HomeRideCard extends StatefulWidget {
  const HomeRideCard({
    super.key,
    required this.description,
    required this.freeSeats,
    required this.offeredSeats,
    required this.eventDate,
    required this.eventImage,
    required this.groupTitle,
    required this.passengers,
    required this.onTap,
    required this.location,
    required this.eventTitle,
    required this.distance,
  });

  final String groupTitle;
  final String description;
  final String eventDate;
  final num offeredSeats;
  final num freeSeats;
  final num distance;
  final String eventImage;
  final List passengers;
  final GeoPoint location;
  final String eventTitle;
  final VoidCallback onTap;

  @override
  State<HomeRideCard> createState() => _HomeRideCardState();
}

class _HomeRideCardState extends State<HomeRideCard> {
  GeoData? _location;

  Future<void> _getLocation() async {
    try {
      print(widget.location.latitude);
      print(widget.location.longitude);
      _location = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
      );
      print(_location);

      setState(() {});
    } catch (e, str) {
      print(e);
      print(str);
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
        decoration: BoxDecoration(
          color: MyColors.kWhiteColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Group and Event info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: MyColors.kWhiteColor,
                  backgroundImage: widget.eventImage.isNotEmpty
                      ? NetworkImage(
                          widget.eventImage,
                        )
                      : null,
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.eventTitle,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: MyColors.kBlackColor),
                      ),
                      Row(
                        children: [
                          Text(
                            '${MyLocalization().group.tr}:',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.groupTitle,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Ride details (location, date, distance)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Details
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${MyLocalization().location.tr}:',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            _location == null ? "" : _location!.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${MyLocalization().date.tr}:',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.eventDate,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${MyLocalization().distance.tr}:',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${widget.distance.toStringAsFixed(2)} Km",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${MyLocalization().offeredSeats.tr}:',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.offeredSeats.toString(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Text(
                              '${MyLocalization().freeSeats.tr}:',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.freeSeats.toString(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
