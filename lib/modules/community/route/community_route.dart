import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/screen/forum_page.dart';

class CommunityRoutes {
  static const tes = '/tes';

  static final Map<String, WidgetBuilder> routes = {
    tes: (context) => ForumPage(),
  };
}
