import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:netly_mobile/modules/lapangan/service/jadwal_service.dart';
import 'package:netly_mobile/modules/lapangan/screen/lapangan_edit_page.dart';
import 'package:netly_mobile/modules/lapangan/screen/jadwal_list_page.dart';
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LapanganDetailPage extends StatefulWidget {
  final String lapanganId;

  const LapanganDetailPage({
    super.key,
    required this.lapanganId,
  });

  


  @override
  State<LapanganDetailPage> createState() => _LapanganDetailPageState();
}

class _LapanganDetailPageState extends State<LapanganDetailPage> {
  late LapanganService _lapanganService;
  late JadwalService _jadwalService;
  bool _isLoading = true;
  Datum? _lapangan;
  String? _errorMessage;

  String getImageUrl() {
    String rawUrl = _lapangan!.image;
    if (rawUrl.isEmpty) return "";
    if (!rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('/')) {
        rawUrl = rawUrl.substring(1); // Hapus slash depan
      }
      rawUrl = "$pathWeb/$rawUrl";
    }

    return "$pathWeb/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
  }
  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _lapanganService = LapanganService(request);
    _jadwalService = JadwalService(request);
    _loadLapanganDetail();
  }

  Future<void> _loadLapanganDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lapangan = await _lapanganService.fetchLapanganDetail(widget.lapanganId);
      setState(() {
        _lapangan = lapangan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
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
          'Are you sure you want to delete "${_lapangan?.name}"?\n\nThis action cannot be undone.',
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final result = await _lapanganService.deleteLapangan(widget.lapanganId);
        
        if (mounted) {
          Navigator.pop(context); // Close loading

          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
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
          Navigator.pop(context);
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

  Future<void> _handleEdit() async {
    if (_lapangan == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LapanganEditPage(lapangan: _lapangan!),
      ),
    );

    if (result == true) {
      _loadLapanganDetail();
    }
  }

  void _navigateToJadwal() {
    if (_lapangan == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JadwalListPage(lapangan: _lapangan!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _lapanganService.isUserAdmin();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLapanganDetail,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _lapangan == null
                  ? const Center(child: Text('Court not found'))
                  : CustomScrollView(
                      slivers: [
                        // App Bar with Image
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          backgroundColor: const Color(0xFF243153),
                          foregroundColor: Colors.white,
                          flexibleSpace: FlexibleSpaceBar(
                            background: _lapangan!.image.isNotEmpty
                                ? Image.network(
                                    getImageUrl(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.sports_tennis,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.sports_tennis,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),

                        // Content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  _lapangan!.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF243153),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Location
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _lapangan!.location,
                                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Price Card
                                Card(
                                  color: const Color(0xFF243153),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Price',
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                        Text(
                                          'Rp ${_lapangan!.price.toString()}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD7FC64),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Description
                                const Text(
                                  'Description',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _lapangan!.description,
                                  style: const TextStyle(fontSize: 16, height: 1.5),
                                ),
                                const SizedBox(height: 24),

                                // Admin Info
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFF243153),
                                          child: Icon(Icons.person, color: Color(0xFFD7FC64)),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Managed by',
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            Text(
                                              _lapangan!.adminName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Jadwal Preview Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Available Schedule',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _navigateToJadwal,
                                      child: const Text('See All'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Jadwal Preview List
                                FutureBuilder<JadwalLapanganModel?>(
                                  future: _jadwalService.fetchJadwalByLapangan(
                                    lapanganId: _lapangan!.id,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'Error loading schedule: ${snapshot.error}',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    }

                                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data.isEmpty) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              const Text('No schedule available yet'),
                                              if (isAdmin) ...[
                                                const SizedBox(height: 8),
                                                ElevatedButton(
                                                  onPressed: _navigateToJadwal,
                                                  child: const Text('View Schedule'),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    // Filter upcoming schedules and sort by date
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);

                                    // Get upcoming schedules (today and future)
                                    final upcomingJadwal = snapshot.data!.data
                                        .where((jadwal) {
                                          final jadwalDate = DateTime(
                                            jadwal.tanggal.year,
                                            jadwal.tanggal.month,
                                            jadwal.tanggal.day,
                                          );
                                          return jadwalDate.isAtSameMomentAs(today) || 
                                                jadwalDate.isAfter(today);
                                        })
                                        .toList();

                                    // Sort by date ascending (nearest first), then by start time
                                    upcomingJadwal.sort((a, b) {
                                      final dateComparison = a.tanggal.compareTo(b.tanggal);
                                      if (dateComparison != 0) return dateComparison;
                                      return a.startMain.compareTo(b.startMain);
                                    });

                                    // Take first 3 upcoming schedules
                                    final jadwalList = upcomingJadwal.take(3).toList();

                                    // If no upcoming schedules, show message
                                    if (jadwalList.isEmpty) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              const Text('No upcoming schedule'),
                                              if (isAdmin) ...[
                                                const SizedBox(height: 8),
                                                ElevatedButton(
                                                  onPressed: _navigateToJadwal,
                                                  child: const Text('Add Schedule'),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: jadwalList.map((jadwal) {
                                        final isPast = jadwal.tanggal.isBefore(
                                          DateTime.now().subtract(const Duration(days: 1)),
                                        );

                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isPast
                                                  ? Colors.grey
                                                  : jadwal.isAvailable
                                                      ? Colors.green
                                                      : Colors.red,
                                              child: Icon(
                                                jadwal.isAvailable ? Icons.check : Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                            title: Text(
                                              DateFormat('EEEE, dd MMM yyyy').format(jadwal.tanggal),
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              '${jadwal.startMain} - ${jadwal.endMain}',
                                            ),
                                            trailing: Chip(
                                              label: Text(
                                                isPast
                                                    ? 'has passed'
                                                    : jadwal.isAvailable
                                                        ? 'Available'
                                                        : 'Full',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: isPast
                                                  ? Colors.grey
                                                  : jadwal.isAvailable
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Admin Actions
                                if (isAdmin) ...[
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Admin Actions',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _handleEdit,
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit Court', style: TextStyle(fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF243153),
                                            foregroundColor: const Color(0xFFD7FC64),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _handleDelete,
                                          icon: const Icon(Icons.delete),
                                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}