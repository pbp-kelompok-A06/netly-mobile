import 'package:flutter/material.dart';
import 'package:netly_mobile/app_route.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AuthRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
