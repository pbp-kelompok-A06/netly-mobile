import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/homepage/screen/home_page.dart';
import 'package:netly_mobile/modules/homepage/screen/favorite_page.dart';
import 'package:netly_mobile/modules/homepage/widgets/bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Index halaman yang sedang aktif
  // 0: Booking, 1: Community, 2: Home (Khusus), 3: Event, 4: Favorites
  int _selectedIndex = 2; // Default mulai di Home

  // Daftar Halaman
  final List<Widget> _pages = [
    const Center(child: Text("Halaman Booking (On Progress)")), // Index 0
    const Center(child: Text("Halaman Community (On Progress)")), // Index 1
    const HomePage(), // Index 2 (HOME)
    const Center(child: Text("Halaman Events (On Progress)")), // Index 3
    const FavoritePage(), // Index 4 (FAVORITES)
  ];

  // Fungsi ganti halaman dari Navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi Tombol Home Tengah
  void _onHomeTapped() {
    setState(() {
      _selectedIndex = 2; // Kembali ke Home
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // === BODY YANG BERUBAH-UBAH ===
      // Menggunakan IndexedStack agar state halaman (seperti scroll position) terjaga
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // === TOMBOL TENGAH (HOME) ===
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: _onHomeTapped,
          backgroundColor: const Color(0xFF243153),
          shape: const CircleBorder(),
          elevation: 4,
          child: Icon(
            Icons.home_rounded,
            color: _selectedIndex == 2 ? const Color(0xFFD7FC64) : Colors.grey, // Aktif/Nonaktif color
            size: 35,
          ),
        ),
      ),

      // === NAVBAR BAWAH ===
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}