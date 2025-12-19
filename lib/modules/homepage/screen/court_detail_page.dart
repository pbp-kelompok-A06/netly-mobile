import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/screen/create_booking_screen.dart';
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
  bool isFavorited = false;
  String selectedLabel = "Lainnya";
  bool isLoading = false;
  bool isCheckingStatus = true;

  final List<String> favoriteLabels = ["Rumah", "Kantor", "Lainnya"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final request = context.read<CookieRequest>();
        checkFavoriteStatus(request);
      }
    });
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade400 : const Color(0xFF243153),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  // Cek Status
  Future<void> checkFavoriteStatus(CookieRequest request) async {
    try {
      final response = await request.get("$pathWeb/api/favorites/");
      
      bool found = false;
      String foundLabel = "Lainnya";

      for (var item in response['results']) {
        String remoteId = item['lapangan']['id'].toString();
        String currentId = widget.court.id.toString();

        if (remoteId == currentId) {
          found = true;
          String serverLabel = item['label'] ?? "Lainnya";
          
          if (favoriteLabels.contains(serverLabel)) {
            foundLabel = serverLabel;
          } else {
            foundLabel = favoriteLabels.firstWhere(
              (element) => element.toLowerCase() == serverLabel.toLowerCase(),
              orElse: () => "Lainnya",
            );
          }
          break;
        }
      }

      if (mounted) {
        setState(() {
          isFavorited = found;
          selectedLabel = foundLabel;
          isCheckingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isCheckingStatus = false);
    }
  }

  String _getDisplayLabel(String val) {
    if (val == "Rumah") return "Home";
    if (val == "Kantor") return "Office";
    return "Other";
  }

  String getImageUrl() {
    String rawUrl = widget.court.image;
    if (!rawUrl.startsWith('http')) {
       if (rawUrl.startsWith('/')) rawUrl = rawUrl.substring(1);
       rawUrl = "$pathWeb/$rawUrl";
    }
    return "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
  }

  Future<void> toggleFavorite(CookieRequest request) async {
    setState(() => isLoading = true);
    final url = "$pathWeb/api/favorites/toggle/${widget.court.id}/";
    
    try {
      final response = await request.post(url, jsonEncode({"label": selectedLabel}));

      if (response['status'] == 'added') {
        setState(() => isFavorited = true);
        _showCustomSnackBar("Saved to Favorites");
      } else if (response['status'] == 'removed') {
        setState(() => isFavorited = false);
        _showCustomSnackBar("Removed from Favorites");
      }
    } catch (e) {
      _showCustomSnackBar("Login required", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateLabel(CookieRequest request, String newLabel) async {
    setState(() => selectedLabel = newLabel);
    
    if (!isFavorited) {
      await toggleFavorite(request);
      return;
    }

    final url = "$pathWeb/api/favorites/toggle/${widget.court.id}/";
    try {
      await request.post(url, {}); 
      await request.post(url, jsonEncode({"label": newLabel}));
      
      _showCustomSnackBar("Label updated to ${_getDisplayLabel(newLabel)}");
    } catch (e) {
    }
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
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: getImageUrl(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
                        ),
                      ),
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
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF243153)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(widget.court.location, style: const TextStyle(color: Colors.grey))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: (isLoading || isCheckingStatus) ? null : () => toggleFavorite(request),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: (isCheckingStatus) 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorited ? Colors.red : Colors.grey,
                                      ),
                                ),
                              ),
                              Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                              
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedLabel,
                                  isDense: true,
                                  dropdownColor: Colors.white, 
                                  borderRadius: BorderRadius.circular(12),
                                  
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                  style: const TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.bold),
                                  items: favoriteLabels.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(_getDisplayLabel(value)),
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

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rp ${widget.court.formattedPrice}",
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w800, 
                    color: Color(0xFF243153)
                  ),
                ),
                
                // Tombol Book
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateBookingScreen(
                          lapanganId: widget.court.id.toString(), // Kirim ID Lapangan
                        ),
                      ),
                    );
                  }, 
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