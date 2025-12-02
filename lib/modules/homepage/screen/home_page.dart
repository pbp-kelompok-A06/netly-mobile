import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/modules/homepage/widgets/home_widget.dart';
import 'package:netly_mobile/utils/path_web.dart';

// Import widget yang sudah kita pisah
import 'package:netly_mobile/modules/homepage/widgets/top_header.dart';
import 'package:netly_mobile/modules/homepage/widgets/filter_modal.dart';
import 'package:netly_mobile/modules/homepage/widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // State Filter
  String? _location; // Untuk Dropdown
  String? _minPrice;
  String? _maxPrice;

  Future<List<Court>> fetchCourts(CookieRequest request) async {
    // Bangun URL dengan parameter Filter
    String url = "$pathWeb/api/courts/?";

    // 1. Search Bar (Bisa cari nama atau kota secara umum)
    if (_searchController.text.isNotEmpty) {
      url += "q=${_searchController.text}&";
    }

    // 2. Location Dropdown (Filter Spesifik Kota)
    if (_location != null && _location!.isNotEmpty) {
      url += "location=$_location&";
    }

    // 3. Price Range
    if (_minPrice != null && _minPrice!.isNotEmpty) {
      url += "min_price=$_minPrice&";
    }
    if (_maxPrice != null && _maxPrice!.isNotEmpty) {
      url += "max_price=$_maxPrice&";
    }

    final response = await request.get(url);

    var data = response;
    List<Court> listCourt = [];
    for (var d in data['results']) {
      if (d != null) {
        listCourt.add(Court.fromJson(d));
      }
    }
    return listCourt;
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FilterModal(
          initialLocation: _location,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          onApply: (loc, min, max) {
            setState(() {
              _location = loc;
              _minPrice = min;
              _maxPrice = max;
            });
            // Fetch ulang otomatis jalan karena setState men-trigger build
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. HEADER (Logo, Search, Filter)
          TopHeader(
            searchController: _searchController,
            onFilterTap: _openFilter,
            onSearchSubmitted: (val) => setState(() {}),
          ),

          // 2. GRID LIST
          Expanded(
            child: FutureBuilder(
              future: fetchCourts(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No courts found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Rasio kartu tinggi
                        ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      return CourtCard(court: snapshot.data![index]);
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
