import 'package:flutter/material.dart';
import 'package:netly_mobile/app_route.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/modules/homepage/route/homepage_route.dart';

import 'package:provider/provider.dart';
import 'package:netly_mobile/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },

      child: MaterialApp(
        title: 'Netly',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF243153)),
          useMaterial3: true,
        ),
        initialRoute: AuthRoutes.login,
        routes: {
          ...AppRoutes.routes,
          '/main': (context) => const MainPage(),
        },
      ),
    );
  }
}
