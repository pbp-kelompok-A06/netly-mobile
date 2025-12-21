import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/utils/path_web.dart';

class LapanganCard extends StatelessWidget {
  final Datum lapangan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const LapanganCard({
    super.key,
    required this.lapangan,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  String getImageUrl() {
    String rawUrl = lapangan.image;
    if (rawUrl.isEmpty) return "";
    if (!rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('/')) {
        rawUrl = rawUrl.substring(1); // Hapus slash depan
      }
      rawUrl = "$pathWeb/$rawUrl";
    }

    return "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
  }

  String formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Fixed height
            SizedBox(
              height: 100, 
              width: double.infinity,
              child: lapangan.image.isNotEmpty
                  ? Image.network(
                      getImageUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_tennis,
                            size: 50,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_tennis,
                        size: 50,
                        color: Colors.white54,
                      ),
                    ),
            ),

            // Content - Flexible height with Expanded
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - Max 2 lines
                    Text(
                      lapangan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), 

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14, 
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lapangan.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12, 
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), 

                    // Price - Using formatPrice method
                    Text(
                      formatPrice(lapangan.price), 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Admin name
                    Text(
                      'Oleh: ${lapangan.adminName}',
                      style: const TextStyle(
                        fontSize: 11, 
                        color: Colors.grey,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, 
                    ),

                    const Spacer(), 

                    // Admin actions - COLORFUL BUTTONS
                    if (isAdmin) ...[
                      const SizedBox(height: 8), 
                      Row(
                        children: [
                          // Edit Button - Navy Blue with Lime Green text
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onEdit,
                              label: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF243153), // Navy blue
                                foregroundColor: const Color(0xFFD7FC64), // Lime green
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Delete Button - Red background with white text
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onDelete,
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}