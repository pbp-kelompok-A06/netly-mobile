import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/screen/forum_show_page.dart';

class CommunityRoutes {
  static const community = '/community';
  
  static final Map<String, WidgetBuilder> routes = {
    community: (context) => ForumShowPage(),
  };
}
