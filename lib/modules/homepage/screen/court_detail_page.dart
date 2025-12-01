import 'dart:convert';
import 'dart:ui' as ui; // ✅ WAJIB ADA untuk backdropFilter (Blur)
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/utils/path_web.dart';

class CourtDetailPage extends StatefulWidget {
  final Court court;

  const CourtDetailPage({super.key, required this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  bool isFavorited = false;
  String selectedLabel = "Lainnya";
  bool isLoading = false;

  final List<String> favoriteLabels = ["Rumah", "Kantor", "Lainnya"];

  String getImageUrl() {
    String url = widget.court.image;
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) url = url.substring(1);
      return "$pathWeb/$url";
    }
    return url;
  }

  Future<void> toggleFavorite(CookieRequest request) async {
    setState(() => isLoading = true);
    final url = "$pathWeb/api/favorites/toggle/${widget.court.id}/";

    try {
      final response = await request.post(
        url,
        jsonEncode({"label": selectedLabel}),
      );

      if (response['status'] == 'added') {
        setState(() => isFavorited = true);
        _showSnackBar("Saved to Favorites ($selectedLabel)", Colors.green);
      } else if (response['status'] == 'removed') {
        setState(() => isFavorited = false);
        _showSnackBar("Removed from Favorites", Colors.grey);
      }
    } catch (e) {
      _showSnackBar("Login required to save favorites", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // === SCROLLABLE CONTENT ===
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO IMAGE
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Image.network(
                          getImageUrl(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[200]),
                        ),
                      ),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4],
                          ),
                        ),
                      ),
                      // Back Button dengan Blur
                      Positioned(
                        top: 50,
                        left: 16,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: ClipRRect(
                            // ClipRRect biar blurnya rounded
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. CONTENT CONTAINER
                  Container(
                    transform: Matrix4.translationValues(0, -20, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.court.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF243153),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.court.location,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // FAVORITE PILL
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: isLoading
                                    ? null
                                    : () => toggleFavorite(request),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          isFavorited
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorited
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 24,
                                        ),
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 1,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedLabel,
                                  isDense: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF243153),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  items: favoriteLabels.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value == "Rumah"
                                            ? "Home"
                                            : (value == "Kantor"
                                                  ? "Office"
                                                  : "Other"),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() => selectedLabel = newValue);
                                      if (isFavorited) toggleFavorite(request);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 24),

                        // About Venue
                        const Text(
                          "About Venue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF243153),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.court.description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === BOTTOM BAR ===
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ FIX UPPERCASE ERROR: Pakai .toUpperCase() di stringnya
                      Text(
                        "Start from".toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "Rp ${widget.court.formattedPrice}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF243153),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "/ hour",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // BOOK NOW
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Redirecting to Booking..."),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF243153),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 5,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Book Now",
                          style: TextStyle(
                            color: Color(0xFFD7FC64),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFD7FC64),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
