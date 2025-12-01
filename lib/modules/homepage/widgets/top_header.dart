import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final Function(String) onSearchSubmitted;

  const TopHeader({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF243153), // Navy Netly
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. LOGO 'N' (Tetap seperti sebelumnya)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "N",
                    style: TextStyle(
                      color: Color(0xFFD7FC64),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              // 2. SEARCH BAR DENGAN TOMBOL KLIK
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    textAlignVertical: TextAlignVertical.center,
                    
                    // Supaya tombol search di keyboard HP tetap jalan
                    onSubmitted: onSearchSubmitted, 
                    
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search courts...",
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(left: 16), // Jarak teks dari kiri
                      
                      // 👇 INI PERUBAHANNYA: Tombol Search di Kanan
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFFD7FC64)), // Warna Lime biar kelihatan tombol
                        onPressed: () {
                          // Panggil fungsi search saat tombol diklik
                          onSearchSubmitted(searchController.text);
                        },
                        tooltip: "Search",
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              // 3. FILTER BUTTON
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7FC64), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF243153),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}