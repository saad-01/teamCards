import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/pages/Home/pages/home_page.dart';

import '../constants.dart';
import '../pages/Groups/Screens/group_add_member_by_link_page.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    if (kDebugMode) {
      print("RouteName: ${routeSettings.name}");
      print(args);
    }

    switch (routeSettings.name) {
      case kHomepageLink:
        return CupertinoPageRoute(builder: (_) {
          return const HomePage();
        });

      /* case kGroupAddLink:
        return CupertinoPageRoute(builder: (_) {
          return const GroupAddMemberPage();
        });*/

      case kGroupAddLink:
        if (args is Map) {
          return CupertinoPageRoute(builder: (_) {
            return GroupAddMemberByLinkPage(groupId: args["groupid"]);
          });
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Page Not Found"),
        ),
      );
    });
  }
}
