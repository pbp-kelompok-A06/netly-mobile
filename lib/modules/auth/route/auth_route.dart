import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/screen/login_page.dart';
import 'package:netly_mobile/modules/auth/screen/register_page.dart';


class AuthRoutes {
  static const login = '/login';
  static const register = '/register';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
  };
}
