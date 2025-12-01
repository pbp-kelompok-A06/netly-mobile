import 'package:flutter/material.dart';
import 'package:netly_mobile/app_route.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/modules/booking/screen/create_booking_screen.dart';

import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
  
void main() async {
  await initializeDateFormatting();
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
          
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: AuthRoutes.login,
        routes: AppRoutes.routes,
        // home : CreateBookingScreen(lapanganId: '9dbed1f9-8953-4cd0-8268-dce2653fdd93'),
      ),
      
    );
  }
}
