import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:netly_mobile/modules/lapangan/widgets/lapangan_card.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_form_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_detail_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_edit_page.dart';
import 'package:netly_mobile/modules/auth/screen/login_page.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LapanganListPage extends StatefulWidget {
  const LapanganListPage({super.key});

  @override
  State<LapanganListPage> createState() => _LapanganListPageState();
}

class _LapanganListPageState extends State<LapanganListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context, CookieRequest request) async {
    final response = await request.logout("$pathWeb/logout-ajax/");

    if (context.mounted) {
      if (response['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDetail(Datum lapangan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LapanganDetailPage(lapanganId: lapangan.id),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list jika ada perubahan
      }
    });
  }

  void _editLapangan(Datum lapangan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LapanganEditPage(lapangan: lapangan),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  Future<void> _deleteLapangan(Datum lapangan) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${lapangan.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final request = context.read<CookieRequest>();
      final lapanganService = LapanganService(request);

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final result = await lapanganService.deleteLapangan(lapangan.id);

        if (mounted) {
          Navigator.pop(context); // Close loading

          if (result['success']) {
            setState(() {}); // Refresh list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _addLapangan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LapanganFormPage()),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF243153),
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFD7FC64), size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final lapanganService = LapanganService(request);

    final size = MediaQuery.of(context).size;
    final height = size.height;

    // Check if user is admin
    final isAdmin = lapanganService.isUserAdmin();

    // Get user data
    String userName = "Guest User";
    String userImage = "";

    if (request.loggedIn) {
      if (request.jsonData.containsKey('userData')) {
        userName = request.jsonData['userData']['username'] ?? 
                   request.jsonData['userData']['full_name'] ?? 
                   request.jsonData['username'] ?? "User"; 
        
        userImage = request.jsonData['userData']['profile_picture'] ?? "";
      } else {
        userName = request.jsonData['username'] ?? "User";
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Top Header with Logout Button
          Container(
            color: const Color(0xFF243153),
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 30, 
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7FC64),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "N", 
                            style: TextStyle(
                              color: Color(0xFF243153), 
                              fontWeight: FontWeight.bold, 
                              fontSize: 20
                            )
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hello,", 
                              style: TextStyle(
                                fontSize: 10, 
                                color: Colors.white70, 
                                fontWeight: FontWeight.w500, 
                                height: 1.0
                              )
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFFD7FC64), 
                                height: 1.2
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Menu with Logout
                PopupMenuButton<String>(
                  offset: const Offset(0, 45),
                  elevation: 2,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  constraints: const BoxConstraints.tightFor(width: 110),
                  
                  child: Container(
                    width: 30, 
                    height: 30,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD7FC64), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), 
                          blurRadius: 8, 
                          offset: const Offset(0, 2)
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: (userImage.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: "$pathWeb/proxy-image/?url=${Uri.encodeComponent(userImage.startsWith('http') ? userImage : "$pathWeb/$userImage")}",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Log Out", 
                            style: TextStyle(
                              color: Colors.red, 
                              fontWeight: FontWeight.normal, 
                              fontSize: 12
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await _handleLogout(context, request);
                    }
                  },
                ),
              ],
            ),
          ),

          // Title Section
          Container(
            width: double.infinity,
            color: const Color(0xFF243153),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              isAdmin ? 'My Court' : 'List of Badminton Courts',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD7FC64),
              ),
            ),
          ),

          // Search Bar
          Container(
            color: const Color(0xFF243153),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 45, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  color: Color(0xFF243153), 
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search courts...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400], 
                    fontSize: 14, 
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  FocusScope.of(context).unfocus(); // Tutup keyboard setelah search
                },
              ),
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<LapanganModel?>(
              future: lapanganService.fetchAllLapangan(search: _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data'));
                }

                final lapanganList = snapshot.data!.data;

                if (lapanganList.isEmpty) {
                  return const Center(child: Text('Data kosong'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      isAdmin ? 100 : 16, // Extra bottom padding for FAB
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 330, // Increased from 300 to 330
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: lapanganList.length,
                    itemBuilder: (context, index) {
                      final lapangan = lapanganList[index];
                      return LapanganCard(
                        lapangan: lapangan,
                        isAdmin: isAdmin,
                        onTap: () => _showDetail(lapangan),
                        onEdit: () => _editLapangan(lapangan),
                        onDelete: () => _deleteLapangan(lapangan),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- Floating Action Button dengan Posisi Fixed ---
      floatingActionButton: isAdmin
          ? Padding(
              padding: EdgeInsets.only(bottom: height * 0.128),
              child: FloatingActionButton.extended(
                onPressed: _addLapangan,
                backgroundColor: const Color(0xFF243153),
                foregroundColor: const Color(0xFFD7FC64),
                icon: const Icon(Icons.add),
                label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                elevation: 4,
                
              ),
            )
          : null,
    );
  }
}