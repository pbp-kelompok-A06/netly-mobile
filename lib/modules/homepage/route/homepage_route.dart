import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/homepage/screen/home_page.dart'; // Import File No 1

class HomepageRoutes {
  static const String home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
  };
}