import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Helper biar kodingan rapi
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;
    return IconButton(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isActive ? const Color(0xFF243153) : Colors.grey, 
            size: 24
          ),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              color: isActive ? const Color(0xFF243153) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )
          )
        ],
      ),
      onPressed: () => onItemTapped(index),
    );
  }

@override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 12.0, 
      
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black,
      elevation: 10,
      height: 70,
      padding: EdgeInsets.zero,
      
      // ClipBehavior agar bayangan navbar rapi
      clipBehavior: Clip.antiAlias, 
      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.calendar_month_outlined, "Booking", 0),
          _buildNavItem(Icons.groups_outlined, "Community", 1),

          const SizedBox(width: 40), 

          _buildNavItem(Icons.emoji_events_outlined, "Events", 3),
          _buildNavItem(Icons.favorite_border, "Favorites", 4),
        ],
      ),
    );
  }
}