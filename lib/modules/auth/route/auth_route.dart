import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/view/login_page.dart';


class AuthRoutes {
  static const login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
  };
}
