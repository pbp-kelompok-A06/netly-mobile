import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/screen/booking_detail_screen.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:netly_mobile/modules/booking/screen/admin_booking_detail_screen.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  late Future<List<Booking>> _futureBookings;
  bool _isAdmin = false;
  bool _isAdminChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _futureBookings = _fetchBookings();
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    final service = BookingService(request: request);
    try {
      final adminInfo = await service.getAdminInfo(request);
      if (mounted) {
        setState(() {
          _isAdmin = adminInfo['is_admin'] == true;
          _isAdminChecked = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _isAdminChecked = true;
        });
      }
    }
  }

  Future<List<Booking>> _fetchBookings() async {
    final request = context.read<CookieRequest>();
    final service = BookingService(request: request);
    try {
      return await service.fetchAllBookings(request);
    } catch (e) {
      return Future.error('Failed to load bookings: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green.shade700;
      case 'failed': return Colors.red.shade700;
      case 'pending': return Colors.orange.shade700;
      default: return Colors.blue.shade700;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green.shade100;
      case 'failed': return Colors.red.shade100;
      case 'pending': return Colors.orange.shade100;
      default: return Colors.blue.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdminChecked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF243153),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFD7FC64))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD7FC64)));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  const Text('Gagal memuat data booking.', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => _futureBookings = _fetchBookings()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat booking.'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 100.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final Widget detailScreen = _isAdmin
                    ? BookingDetailAdminScreen(bookingId: booking.id)
                    : BookingDetailScreen(bookingId: booking.id);
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => detailScreen),
                    ).then((_) => setState(() => _futureBookings = _fetchBookings()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3)),
                      ],
                      border: Border.all(color: _getStatusColor(booking.statusBook).withOpacity(0.5), width: 1.0)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                booking.lapangan.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF243153)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(booking.statusBook),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                booking.statusBook.toUpperCase(),
                                style: TextStyle(color: _getStatusColor(booking.statusBook), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Harga', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(booking.totalPrice)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Dibuat pada', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(booking.createdAt),
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lihat Detail >',
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}