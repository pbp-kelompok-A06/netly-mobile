import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/modules/community/route/community_route.dart';
import 'package:netly_mobile/modules/lapangan/route/lapangan_route.dart';
import 'package:netly_mobile/modules/event/route/event_route.dart';


class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    ...AuthRoutes.routes,
    ...CommunityRoutes.routes,
    ...LapanganRoutes.routes,
    ...EventRoutes.routes,
  };
}
