import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/homepage/screen/court_detail_page.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favoriteItem;
  final Function(String) onRemove;

  final VoidCallback? onCardTap;

  const FavoriteCard({
    super.key,
    required this.favoriteItem,
    required this.onRemove,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final court = favoriteItem.lapangan;

    Color badgeBgColor;
    Color badgeTextColor;
    String labelText;

    if (favoriteItem.label == 'Rumah') {
      badgeBgColor = Colors.blue.shade50;
      badgeTextColor = const Color(0xFF243153);
      labelText = "Home";
    } else if (favoriteItem.label == 'Kantor') {
      badgeBgColor = Colors.purple.shade50;
      badgeTextColor = Colors.purple.shade800;
      labelText = "Office";
    } else {
      badgeBgColor = Colors.grey.shade100;
      badgeTextColor = Colors.grey.shade600;
      labelText = "Other";
    }

    String rawUrl = court.image;
    if (!rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('/')) rawUrl = rawUrl.substring(1);
      rawUrl = "$pathWeb/$rawUrl";
    }
    String proxyUrl = "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onCardTap,
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 100, 
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: proxyUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.blue.shade50,
                          child: Icon(Icons.sports_tennis, size: 40, color: Colors.blue.shade200),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tombol Hapus (Pojok Kanan Atas)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => onRemove(favoriteItem.id),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Group Nama & Lokasi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF243153),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  court.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Group Harga & Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                          
                          // Label Badge (Rumah/Kantor)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: badgeTextColor.withOpacity(0.1)),
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