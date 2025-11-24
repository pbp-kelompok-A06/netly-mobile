import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';


class AppRoutes {

  static final Map<String, WidgetBuilder> routes = {
    ...AuthRoutes.routes,
  };
}
