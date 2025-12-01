import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/homepage/screen/court_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Import Package Baru

class CourtCard extends StatelessWidget {
  final Court court;
  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    // Logic URL Gambar
    String imageUrl = court.image;
    if (!imageUrl.startsWith('http')) {
      if (imageUrl.startsWith('/')) {
        imageUrl = imageUrl.substring(1); 
      }
      imageUrl = "$pathWeb/$imageUrl"; 
    }

    return Container(
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
              // === GAMBAR PAKAI CACHED NETWORK IMAGE ===
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 135,
                  width: double.infinity,
                  // 👇 GANTI BAGIAN INI
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    // Tampilan saat loading
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    // Tampilan jika error (misal CORS)
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
                            SizedBox(height: 4),
                            Text("Failed to load", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // === TEKS INFO (TETAP SAMA) ===
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Text(
                        "Rp ${court.formattedPrice}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF243153),
                        ),
                      ),
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