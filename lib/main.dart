import 'package:flutter/material.dart';
import 'package:netly_mobile/app_route.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/modules/event/screen/event_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(117, 167, 24, 1),
    );

    return MaterialApp(
      title: 'Netly',
      theme: ThemeData(
        colorScheme: colorScheme,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      // initialRoute: AuthRoutes.login,
      // routes: AppRoutes.routes,
      home: const EventPage(),
    );
  }
}
