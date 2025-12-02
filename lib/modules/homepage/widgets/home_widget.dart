import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/homepage/screen/court_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourtCard extends StatelessWidget {
  final Court court;
  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    // === LOGIC PROXY IMAGE (RAHASIA SUPAYA MUNCUL DI CHROME) ===
    String rawUrl = court.image;
    
    // 1. Jika URL relatif (/media/...), jadikan absolut dulu
    if (!rawUrl.startsWith('http')) {
       if (rawUrl.startsWith('/')) rawUrl = rawUrl.substring(1);
       rawUrl = "$pathWeb/$rawUrl";
    }

    // 2. Bungkus URL asli ke dalam Proxy Django
    // encodeComponent() penting agar karakter spesial di URL aman
    String proxyUrl = "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";

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
              // === GAMBAR (PAKAI PROXY URL) ===
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 135,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: proxyUrl, // 👈 PAKAI URL PROXY
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
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