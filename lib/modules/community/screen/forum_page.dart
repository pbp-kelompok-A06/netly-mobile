import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/modules/booking/route/booking_route.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumBar extends StatelessWidget {
  const ForumBar({required this.title, super.key});

  // Fields in a Widget subclass are always marked "final".

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),
      // Row is a horizontal, linear layout.
      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null, // null disables the button
          ),
          // Expanded expands its child
          // to fill the available space.
          Expanded(child: title),
          const IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      child: Column(
        children: [
          ForumBar(
            title: Text(
              'Example title',
              style:
                  Theme.of(context) //
                      .primaryTextTheme
                      .titleLarge,
            ),
          ),
          const Expanded(child: Center(child: Text('Hello, world!'))),

          ElevatedButton(
            onPressed: () async {
              final response = await request.logout("$pathWeb/logout-ajax/");
              if (response['status'] == 'success') {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: AuthRoutes.routes[AuthRoutes.login]!,
                    ),
                  );
                }
              }
            },

            child: Text("Logout"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: BookingRoutes.routes[BookingRoutes.tes2]!,
                ),
              );
            },

            child: Text("Booking"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: BookingRoutes.routes[BookingRoutes.tes3]!,
                ),
              );
            },

            child: Text("Booking List"),
          ),
                    ElevatedButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: BookingRoutes.routes[BookingRoutes.tes3]!,
                ),
              );
            },

            child: Text("Booking create"),
          ),
          
        ],
      ),
    );
  }
}
