import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/modules/community/route/community_route.dart';
import 'package:netly_mobile/modules/booking/route/booking_route.dart';


class AppRoutes {

  static final Map<String, WidgetBuilder> routes = {
    ...AuthRoutes.routes,
    ...CommunityRoutes.routes,
    ...BookingRoutes.routes,
  };
}
