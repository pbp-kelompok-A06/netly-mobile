import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:netly_mobile/modules/lapangan/widgets/lapangan_card.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_form_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_detail_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_edit_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final lapanganService = LapanganService(request);

    // Check if user is admin
    final isAdmin = lapanganService.isUserAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? 'My Court' : 'List of Badminton Courts',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                hintText: 'Search...',
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
                          'There is an error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data'));
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
                              ? isAdmin
                                    ? 'You dont have a court yet'
                                    : 'There is no court yet'
                              : 'No results for "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (isAdmin && _searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addLapangan,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Field'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF243153),
                              foregroundColor: const Color(0xFFD7FC64),
                            ),
                          ),
                        ],
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
                          childAspectRatio: 0.8,
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
      floatingActionButton: isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0), 
              child: FloatingActionButton.extended(
                onPressed: _addLapangan,
                backgroundColor: const Color(0xFFD7FC64),
                foregroundColor: const Color(0xFF243153),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            )
            : null,
    );
  }
}
