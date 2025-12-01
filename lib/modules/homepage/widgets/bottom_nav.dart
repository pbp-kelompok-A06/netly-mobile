import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // Ini yang bikin lengkungan (Coak)
      notchMargin: 8.0, // Jarak antara tombol Home dengan lengkungan putih
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black,
      elevation: 10,
      height: 70, // Tinggi bar
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Biar jaraknya rata
        children: [
          // === KIRI (2 MENU) ===
          
          // 1. My Booking
          IconButton(
            icon: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 24),
                Text("Booking", style: TextStyle(fontSize: 10, color: Colors.grey))
              ],
            ),
            onPressed: () {},
          ),

          // 2. Community
          IconButton(
            icon: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_outlined, color: Colors.grey, size: 24),
                Text("Community", style: TextStyle(fontSize: 10, color: Colors.grey))
              ],
            ),
            onPressed: () {},
          ),

          // === SPACER TENGAH (Jarak buat tombol Home) ===
          const SizedBox(width: 40), 

          // === KANAN (2 MENU) ===

          // 3. Event & Tournament
          IconButton(
            icon: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.grey, size: 24),
                Text("Events", style: TextStyle(fontSize: 10, color: Colors.grey))
              ],
            ),
            onPressed: () {},
          ),

          // 4. Favorites
          IconButton(
            icon: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, color: Colors.grey, size: 24),
                Text("Favorites", style: TextStyle(fontSize: 10, color: Colors.grey))
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}