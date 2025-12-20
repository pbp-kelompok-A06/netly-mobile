import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/booking/screen/booking_list_screen.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:intl/intl.dart';

class BookingDetailAdminScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailAdminScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailAdminScreen> createState() =>
      _BookingDetailAdminScreenState();
}

class _BookingDetailAdminScreenState extends State<BookingDetailAdminScreen> {
  late Future<Booking> _futureBooking;
  late BookingService _service;

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final request = Provider.of<CookieRequest>(context);
    _service = BookingService(request: request);

    _fetchBookingDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchBookingDetail() {
    setState(() {
      _futureBooking = _service.fetchBookingDetail(
        widget.bookingId,
        _service.request,
      );
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Anda yakin ingin menghapus booking #${widget.bookingId}? Tindakan ini tidak dapat dibatalkan dan jadwal yang belum terlewat akan dibuka kembali.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBooking(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking(BuildContext context) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.deleteBookingAsAdmin(widget.bookingId);

      if (!mounted) return;

      Future.microtask(() {
        if (mounted) {
          Navigator.pop(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const BookingListPage();
              },
            ),
          );
        }
      });
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus booking: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.grey;
      case 'pending':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Booking (Admin) #$widget.bookingId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : FutureBuilder<Booking>(
              future: _futureBooking,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gagal memuat detail booking: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchBookingDetail,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Detail booking tidak ditemukan.'),
                  );
                }

                final booking = snapshot.data!;
                final currencyFormatter = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Detail Booking ${booking.id}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                      ),
                      const SizedBox(height: 30),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Booking:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              _buildDetailRow(
                                context,
                                Icons.sports_soccer,
                                'Lapangan',
                                booking.lapangan.name,
                              ),
                              _buildDetailRow(
                                context,
                                Icons.date_range,
                                'Dibuat Pada',
                                DateFormat(
                                  'dd MMMM yyyy, HH:mm',
                                ).format(booking.createdAt),
                              ),
                              _buildDetailRow(
                                context,
                                Icons.attach_money,
                                'Total Harga',
                                currencyFormatter.format(booking.totalPrice),
                              ),
                              _buildDetailRow(
                                context,
                                Icons.receipt_long,
                                'Status',
                                booking.statusBook.toUpperCase(),
                                valueColor: _getStatusColor(booking.statusBook),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jadwal yang Dibooking:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),

                              if (booking.jadwal.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Tidak ada slot jadwal yang terkait.',
                                  ),
                                )
                              else
                                ...booking.jadwal.map((jadwal) {
                                  final date = DateFormat(
                                    'dd MMM yyyy',
                                  ).format(jadwal.tanggal);
                                  final time =
                                      '${jadwal.startMain}:00 - ${jadwal.endMain}:00';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.teal,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$date, $time',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Pemesan:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.red.shade800),
                              ),
                              const Divider(color: Colors.red),

                              _buildDetailRow(
                                context,
                                Icons.person,
                                'Nama Lengkap',
                                booking.userFullname,
                              ),
                              _buildDetailRow(
                                context,
                                Icons.perm_identity,
                                'User ID',
                                booking.userId,
                                valueColor: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Aksi Admin:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _showDeleteConfirmationDialog(context),
                        icon: const Icon(Icons.delete_forever),
                        label: Text(
                          _isLoading ? 'Processing...' : 'Delete Booking',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
