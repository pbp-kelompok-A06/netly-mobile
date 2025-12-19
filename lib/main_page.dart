import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/screen/booking_list_screen.dart';
import 'package:netly_mobile/modules/community/screen/forum_show_page.dart';
import 'package:netly_mobile/modules/homepage/screen/home_page.dart';
import 'package:netly_mobile/modules/homepage/screen/favorite_page.dart';
import 'package:netly_mobile/modules/homepage/widgets/bottom_nav.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_list_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // Default Home
  bool _isHomePressed = false;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onHomeTapped() {
    setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = const BookingListPage();
        break;
      case 1:
        bodyContent = const ForumShowPage();
        break;
      case 2:
        if(request.jsonData['userData']['role'] == 'admin'){
          bodyContent = const LapanganListPage();
        }else{
          bodyContent = const HomePage();
        }

        break;
      case 3:
        bodyContent = const Center(child: Text("Halaman Events (On Progress)"));
        break;
      case 4:
        bodyContent = const FavoritePage();
        break;
      default:
       if(request.jsonData['userData']['role'] == 'admin'){
          bodyContent = const LapanganListPage();
        }else{
          bodyContent = const HomePage();
        } 
        break;

    }

    return Scaffold(
      backgroundColor: Colors.grey[50],

      extendBody: true,

      body: bodyContent,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTapDown: (_) => setState(() => _isHomePressed = true),
        onTapUp: (_) {
          setState(() => _isHomePressed = false);
          _onHomeTapped();
        },
        onTapCancel: () => setState(() => _isHomePressed = false),

        child: AnimatedScale(
          scale: _isHomePressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF243153),
              shape: BoxShape.circle,
              boxShadow: _isHomePressed
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Color(0xFFD7FC64),
              size: 35,
            ),
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
