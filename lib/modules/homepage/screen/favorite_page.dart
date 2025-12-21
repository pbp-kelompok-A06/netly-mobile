import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/homepage/screen/court_detail_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/modules/homepage/widgets/favorite_card.dart';
import 'package:netly_mobile/utils/path_web.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // State Filter 
  String _selectedLabel = ''; 
  
  final Color navyColor = const Color(0xFF243153);
  final Color limeColor = const Color(0xFFD7FC64);

  // Fetch Data dari Django
  Future<List<Favorite>> fetchFavorites(CookieRequest request) async {
    String url = "$pathWeb/api/favorites/?";
    if (_selectedLabel.isNotEmpty) {
      url += "label=$_selectedLabel";
    }

    final response = await request.get(url);
    
    List<Favorite> listFav = [];
    for (var d in response['results']) {
      if (d != null) {
        listFav.add(Favorite.fromJson(d));
      }
    }
    return listFav;
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    // Hapus snackbar lama biar ga numpuk
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Isi Pesan (Icon + Teks)
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
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
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

  // Logic Hapus
  Future<void> removeFavorite(CookieRequest request, String favId) async {
    // Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Remove Favorite"),
        content: const Text("Are you sure you want to remove this court?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Remove", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final url = "$pathWeb/api/favorites/remove/$favId/";
      try {
        final response = await request.post(url, {});
        if (response['status'] == 'success') {
          _showCustomSnackBar("Removed from favorites");
          setState(() {}); 
        }
      } catch (e) {
        _showCustomSnackBar("Failed to remove", isError: true);
      }
    }
  }

  // Widget Tombol Filter (Pill Shape)
  Widget _buildFilterChip(String label, String text) {
    bool isSelected = _selectedLabel == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedLabel = label),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? navyColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? navyColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? limeColor : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    var size = MediaQuery.of(context).size;

    final double itemHeight = 250;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF243153)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('', 'All'),
                  _buildFilterChip('Rumah', '🏠 Near Home'),
                  _buildFilterChip('Kantor', '🏢 Near Office'),
                  _buildFilterChip('Lainnya', '📍 Others'), 
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder(
              future: fetchFavorites(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No favorites found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: (itemWidth / itemHeight),
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      final favoriteItem = snapshot.data![index];

                      return FavoriteCard(
                        favoriteItem: favoriteItem,
                        onRemove: (id) => removeFavorite(request, id),

                        onCardTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourtDetailPage(court: favoriteItem.lapangan), 
                            ),
                          );

                          if (mounted) {
                            setState(() {
                            });
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}