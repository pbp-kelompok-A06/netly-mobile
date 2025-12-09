import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/event/screen/event_page.dart';

class EventRoutes {
  static const String eventPage = '/event';

  static final Map<String, WidgetBuilder> routes = {
    eventPage: (context) => const EventPage(),
  };
}
