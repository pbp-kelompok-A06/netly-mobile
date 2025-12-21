import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/jadwal_service.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:netly_mobile/modules/lapangan/screen/jadwal_form_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class JadwalListPage extends StatefulWidget {
  final Datum lapangan;

  const JadwalListPage({
    super.key,
    required this.lapangan,
  });

  @override
  State<JadwalListPage> createState() => _JadwalListPageState();
}

class _JadwalListPageState extends State<JadwalListPage> {
  late JadwalService _jadwalService;
  late LapanganService _lapanganService;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _jadwalService = JadwalService(request);
    _lapanganService = LapanganService(request);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF243153),
              onPrimary: Color(0xFFD7FC64),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleDelete(JadwalData jadwal) async {
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
          'Are you sure you want to delete this schedule?\n\Date: ${DateFormat('dd MMM yyyy').format(jadwal.tanggal)}\nTime: ${jadwal.startMain} - ${jadwal.endMain}',
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
        final result = await _jadwalService.deleteJadwal(jadwal.id);

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

  Future<void> _handleEdit(JadwalData jadwal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JadwalFormPage(
          lapangan: widget.lapangan,
          jadwal: jadwal,
        ),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _lapanganService.isUserAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Badminton Court Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.lapangan.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _selectDate(context),
            tooltip: 'Date Filter',
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
              tooltip: 'Delete Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Info
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFD7FC64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF243153),
                    ),
                  ),
                ],
              ),
            ),

          // Jadwal List
          Expanded(
            child: FutureBuilder<JadwalLapanganModel?>(
              future: _jadwalService.fetchJadwalByLapangan(
                lapanganId: widget.lapangan.id,
                filterDate: _selectedDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data'));
                }

                final jadwalList = snapshot.data!.data;

                if (jadwalList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDate != null
                              ? 'There are no schedules on this date'
                              : 'There is no schedule yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final groupedJadwal = <String, List<JadwalData>>{};
                for (var jadwal in jadwalList) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(jadwal.tanggal);
                  if (!groupedJadwal.containsKey(dateKey)) {
                    groupedJadwal[dateKey] = [];
                  }
                  groupedJadwal[dateKey]!.add(jadwal);
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedJadwal.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedJadwal.keys.elementAt(index);
                      final date = DateTime.parse(dateKey);
                      final jadwalOnDate = groupedJadwal[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: EdgeInsets.only(bottom: 8, top: index > 0 ? 16 : 0),
                            child: Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(date),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF243153),
                              ),
                            ),
                          ),

                          // Jadwal Cards
                          ...jadwalOnDate.map((jadwal) => _buildJadwalCard(
                                jadwal,
                                isAdmin,
                              )),
                        ],
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JadwalFormPage(lapangan: widget.lapangan),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              backgroundColor: const Color(0xFFD7FC64),
              foregroundColor: const Color(0xFF243153),
              icon: const Icon(Icons.add),
              label: const Text('Add Schedule'),
            )
          : null,
    );
  }

  Widget _buildJadwalCard(JadwalData jadwal, bool isAdmin) {
    final isPast = jadwal.tanggal.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Time
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Color(0xFF243153)),
                      const SizedBox(width: 8),
                      Text(
                        '${jadwal.startMain} - ${jadwal.endMain}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPast
                        ? Colors.grey
                        : jadwal.isAvailable
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPast
                        ? 'Has passed'
                        : jadwal.isAvailable
                            ? 'Available'
                            : 'Not available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Admin Actions
            if (isAdmin && !isPast) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleEdit(jadwal),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDelete(jadwal),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}