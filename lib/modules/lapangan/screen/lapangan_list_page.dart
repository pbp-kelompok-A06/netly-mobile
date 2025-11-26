import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:netly_mobile/modules/lapangan/widgets/lapangan_card.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_form_page.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDetail(Datum lapangan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail ${lapangan.name} - Fitur dalam pengembangan'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _editLapangan(Datum lapangan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${lapangan.name} - Fitur dalam pengembangan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteLapangan(Datum lapangan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${lapangan.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur hapus dalam pengembangan'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final lapanganService = LapanganService(request);

    // Check if user is admin
    final userData = request.jsonData['userData'];
    print(request.jsonData);
    final bool isAdmin = userData != null && userData['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Lapangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF243153),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lapangan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Tidak ada data'));
                }

                final lapanganList = snapshot.data!.data;

                if (lapanganList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_tennis,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada lapangan'
                              : 'Tidak ada hasil untuk "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
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
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _addLapangan,
              backgroundColor: const Color(0xFFD7FC64),
              foregroundColor: const Color(0xFF243153),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
    );
  }
}
