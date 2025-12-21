import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/homepage/model/home_model.dart';
import 'package:netly_mobile/modules/homepage/widgets/home_widget.dart';
import 'package:netly_mobile/utils/path_web.dart';

import 'package:netly_mobile/modules/homepage/widgets/top_header.dart';
import 'package:netly_mobile/modules/homepage/widgets/filter_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // State Filter
  String? _location; // Untuk Dropdown
  String? _minPrice;
  String? _maxPrice;

  void resetToInitial() {
    setState(() {
      _searchController.clear(); // Hapus teks search
      _location = null; // Reset dropdown
      _minPrice = null; // Reset harga
      _maxPrice = null;
      FocusManager.instance.primaryFocus
          ?.unfocus(); // Tutup keyboard jika terbuka
    });
  }

  Future<List<Court>> fetchCourts(CookieRequest request) async {
    // Bangun URL dengan parameter Filter
    String url = "$pathWeb/api/courts/?";

    // Search Bar (Bisa cari nama atau kota secara umum)
    if (_searchController.text.isNotEmpty) {
      url += "q=${_searchController.text}&";
    }

    // Location Dropdown (Filter Spesifik Kota)
    if (_location != null && _location!.isNotEmpty) {
      url += "location=$_location&";
    }

    // Price Range
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

    var size = MediaQuery.of(context).size;

    final double itemHeight = 250;
    final double itemWidth = size.width / 2;

    String userName = "Guest User";
    String userImage = "";

    if (request.loggedIn) {
      if (request.jsonData.containsKey('userData')) {
        userName =
            request.jsonData['userData']['username'] ??
            request.jsonData['userData']['full_name'] ??
            request.jsonData['username'] ??
            "User";

        userImage = request.jsonData['userData']['profile_picture'] ?? "";
      } else {
        userName = request.jsonData['username'] ?? "User";
      }
    }

    return Column(
      children: [
        // (Logo, Search, Filter)
        TopHeader(
          searchController: _searchController,
          onFilterTap: _openFilter,
          onSearchSubmitted: (val) => setState(() {}),
          // Kirim Data User ke TopHeader
          userName: userName,
          userProfileImage: userImage,
        ),

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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: (itemWidth / itemHeight),
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
    );
  }
}
