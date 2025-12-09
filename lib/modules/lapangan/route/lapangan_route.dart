import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_list_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_form_page.dart';

class LapanganRoutes {
  static const list = '/lapangan';
  static const form = '/lapangan/form';

  static final Map<String, WidgetBuilder> routes = {
    list: (context) => const LapanganListPage(),
    form: (context) => const LapanganFormPage(),
  };
}