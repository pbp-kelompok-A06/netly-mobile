import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourtDetailPage extends StatefulWidget {
  final Court court;

  const CourtDetailPage({super.key, required this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  // State
  bool isFavorited = false; // Status hati (Merah/Putih)
  String selectedLabel = "Lainnya"; // Default value DB
  bool isLoading = false; // Loading saat klik tombol
  bool isChecking = true; // Loading awal saat cek status ke server

  final List<String> favoriteLabels = ["Rumah", "Kantor", "Lainnya"];

  @override
  void initState() {
    super.initState();
    // 👇 LOGIC UTAMA: Cek status ke server saat halaman baru dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final request = context.read<CookieRequest>();
        checkFavoriteStatus(request);
      }
    });
  }

  // Fungsi Cek Status: "Server, lapangan ini ada di list favorit user gak?"
  Future<void> checkFavoriteStatus(CookieRequest request) async {
    try {
      final response = await request.get("$pathWeb/api/favorites/");
      
      bool found = false;
      String foundLabel = "Lainnya";

      for (var item in response['results']) {
        // Cek apakah ID Lapangan di list favorit == ID Lapangan halaman ini
        if (item['lapangan']['id'].toString() == widget.court.id.toString()) {
          found = true;
          foundLabel = item['label'] ?? "Lainnya";
          break;
        }
      }

      if (mounted) {
        setState(() {
          isFavorited = found; // Kalau ketemu, jadi TRUE (Merah)
          selectedLabel = foundLabel; // Update label sesuai yang disimpan
          isChecking = false; // Selesai loading
        });
      }
    } catch (e) {
      print("Error checking status: $e");
      if (mounted) setState(() => isChecking = false);
    }
  }

  // Helper Translate Label (DB -> Tampilan UI)
  String _getDisplayLabel(String val) {
    if (val == "Rumah") return "Home";
    if (val == "Kantor") return "Office";
    return "Other";
  }

  // Helper URL Gambar (Pakai Proxy Image)
  String getImageUrl() {
    String rawUrl = widget.court.image;
    // 1. Pastikan Absolute URL
    if (!rawUrl.startsWith('http')) {
       if (rawUrl.startsWith('/')) rawUrl = rawUrl.substring(1);
       rawUrl = "$pathWeb/$rawUrl";
    }
    // 2. Bungkus dengan Proxy agar muncul di Chrome
    return "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
  }

  // Logic Toggle (Klik Hati)
  Future<void> toggleFavorite(CookieRequest request) async {
    setState(() => isLoading = true);
    final url = "$pathWeb/api/favorites/toggle/${widget.court.id}/";
    
    try {
      final response = await request.post(url, jsonEncode({"label": selectedLabel}));

      if (response['status'] == 'added') {
        setState(() => isFavorited = true);
        _showSnackBar("Saved to Favorites", Colors.green);
      } else if (response['status'] == 'removed') {
        setState(() => isFavorited = false);
        _showSnackBar("Removed from Favorites", Colors.grey);
      }
    } catch (e) {
      _showSnackBar("Login required", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Logic Update Label Dropdown
  Future<void> updateLabel(CookieRequest request, String newLabel) async {
    setState(() => selectedLabel = newLabel);
    if (!isFavorited) {
      await toggleFavorite(request);
      return;
    }
    final url = "$pathWeb/api/favorites/toggle/${widget.court.id}/";
    try {
      await request.post(url, jsonEncode({"label": newLabel}));
      _showSnackBar("Label updated", Colors.blue);
    } catch (e) {
      print("Error updating label: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === HERO IMAGE (PROXY + CACHED IMAGE) ===
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: getImageUrl(), // Pakai URL Proxy
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.blue.shade600],
                              ),
                            ),
                            child: const Center(child: Icon(Icons.sports_tennis, color: Colors.white54, size: 64)),
                          ),
                        ),
                      ),
                      // Back Button
                      Positioned(
                        top: 50, left: 16,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Container(
                    transform: Matrix4.translationValues(0, -20, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.court.name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF243153), height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(widget.court.location, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // === FAVORITE PILL (HEART & DROPDOWN) ===
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Hati (Penting)
                              InkWell(
                                onTap: (isLoading || isChecking) ? null : () => toggleFavorite(request),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: (isChecking) 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorited ? Colors.red : Colors.grey, // Merah kalau Favorited
                                        size: 24,
                                      ),
                                ),
                              ),
                              Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                              
                              // Dropdown Label
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedLabel,
                                  isDense: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                  style: const TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.bold),
                                  items: favoriteLabels.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(_getDisplayLabel(value)), // Tampilan UI English
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) updateLabel(request, newValue);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24), const Divider(), const SizedBox(height: 24),
                        const Text("About Venue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF243153))),
                        const SizedBox(height: 12),
                        Text(widget.court.description, textAlign: TextAlign.justify, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("START FROM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text("Rp ${widget.court.formattedPrice}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243153))),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {}, // TODO: Booking
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF243153),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text("Book Now", style: TextStyle(color: Color(0xFFD7FC64), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}