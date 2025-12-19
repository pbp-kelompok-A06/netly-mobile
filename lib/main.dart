import 'package:flutter/material.dart';
import 'package:netly_mobile/app_route.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
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
    return Provider<CookieRequest>(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'Netly',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(117, 167, 24, 1),
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AuthRoutes.login,
        routes: {
          ...AppRoutes.routes, 
          '/main': (context) => const MainPage()
        },
      ),
    );
  }
}
