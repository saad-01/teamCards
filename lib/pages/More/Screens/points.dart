import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../Widgets/points_card_widget.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({
    super.key,
    required this.selected,
    required this.drivenKm,
    required this.offered,
  });

  final double offered;
  final double selected;
  final double drivenKm;

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  late final List<double> values;
  final List<Color> barcolors = [
    MyColors.kGreenColor,
    const Color(0xff00C897),
    const Color(0xff95C11F)
  ];

  @override
  void initState() {
    super.initState();
    values = [widget.offered, widget.drivenKm, widget.selected];
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
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: PointScreenCard(
                      url: 'assets/settings/totalpoint.png',
                      distance: currentUserInformations.points.toString(),
                      title: MyLocalization().totalPoints.tr,
                      color: MyColors.kGreenColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.only(bottom: 5, top: 5, left: 30),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: MyColors.kWhiteColor,
                        border: Border.all(color: MyColors.kBlackColor, width: .3),
                        borderRadius: BorderRadius.circular(14)),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.start,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        minY: 0,
                        maxY: 15,
                        barGroups: List.generate(
                          values.length,
                          (index) {
                            double value = values[index];
                            if(values[index] > 10000) {
                              value = 15;
                            }
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: barcolors[index],
                                  width: 25,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: PointScreenCard(
                      url: 'assets/settings/seatoffered.png',
                      distance: values[0].round().toString(),
                      title: MyLocalization().seatsOffered.tr,
                      color: MyColors.kGreenColor,
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: PointScreenCard(
                      url: 'assets/settings/seatselected.png',
                      distance: values[2].round().toString(),
                      title: MyLocalization().selectedSeats.tr,
                      color: const Color(0xff95C11F),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                    child: PointScreenCard(
                      url: 'assets/settings/kmdriven.png',
                      distance: values[1].toStringAsFixed(2),
                      title: MyLocalization().drivenKm.tr,
                      color: const Color(0xff00C897),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: MyColors.kGreenColor,
              child: AppBarBackArrowWidget(
                textt: MyLocalization().points.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
