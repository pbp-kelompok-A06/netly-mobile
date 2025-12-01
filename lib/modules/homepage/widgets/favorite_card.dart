import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/homepage/screen/court_detail_page.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favoriteItem;
  final Function(String) onRemove;

  const FavoriteCard({
    super.key,
    required this.favoriteItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final court = favoriteItem.lapangan;
    
    // === Logic Warna Badge ===
    Color badgeBgColor;
    Color badgeTextColor;
    String labelText;

    if (favoriteItem.label == 'Rumah') {
      badgeBgColor = Colors.blue.shade50;
      badgeTextColor = const Color(0xFF243153);
      labelText = "🏠 Home";
    } else if (favoriteItem.label == 'Kantor') {
      badgeBgColor = Colors.purple.shade50;
      badgeTextColor = Colors.purple.shade800;
      labelText = "🏢 Office";
    } else {
      badgeBgColor = Colors.grey.shade100;
      badgeTextColor = Colors.grey.shade600;
      labelText = "📍 Other";
    }

    // === Logic URL Gambar ===
    String imageUrl = court.image;
    if (!imageUrl.startsWith('http')) {
      if (imageUrl.startsWith('/')) imageUrl = imageUrl.substring(1);
      imageUrl = "$pathWeb/$imageUrl";
    }

    return Container(
      // ✅ Desain Container sama persis dengan home_widget
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourtDetailPage(court: court),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER: GAMBAR & TOMBOL DELETE (STACK) ===
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 135, // Tinggi disamakan dengan home_widget
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.sports_tennis, size: 48, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tombol Hapus (Pojok Kanan Atas)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => onRemove(favoriteItem.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                          ]
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),

              // === INFO TEXT ===
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // Padding disamakan
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian Atas: Nama & Lokasi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF243153),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  court.location,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Bagian Bawah: Harga & Badge Label (Pakai Row biar sejajar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end, // Biar text align bawah
                        children: [
                          // Harga
                          Text(
                            "Rp ${court.formattedPrice}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF243153),
                            ),
                          ),
                          
                          // Badge Label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: badgeTextColor.withOpacity(0.2)),
                            ),
                            child: Text(
                              labelText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
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