

import 'package:flutter/material.dart';
// Asumsi: File ini sekarang mengekspor class 'Booking' alih-alih 'BookingModel'
// dan field di dalamnya konsisten dengan yang dibutuhkan (lapangan, totalPrice, statusBook, createdAt, id).
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/route/booking_route.dart';
import 'package:netly_mobile/modules/booking/screen/booking_detail_screen.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart'; // Import BookingService yang Anda sediakan
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  // Disesuaikan untuk menggunakan class Booking (sesuai BookingService Anda)
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    // Memanggil _fetchBookings saat widget dibuat
    _futureBookings = _fetchBookings();
  }

  // Fungsi untuk memuat data menggunakan BookingService
  // Disesuaikan untuk menggunakan class Booking (sesuai BookingService Anda)
  Future<List<Booking>> _fetchBookings() async {
    final request = context.read<CookieRequest>();
    final service = BookingService(request: request);

    try {
      // Menggunakan fetchBookings dari Service yang mengembalikan List<Booking>
      return await service.fetchAllBookings(request);
    } catch (e) {
      print('Failed to load bookings via Service: $e');

      if (context.mounted) {
        // Pesan error diambil dari Exception yang dilempar oleh service
        _showErrorDialog(
          context,
          'Gagal memuat riwayat booking: ${e.toString().replaceFirst('Exception: ', '')}. Pastikan Anda sudah login.',
        );
      }
      return Future.error('Failed to load bookings: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243153), // primary-dark
        foregroundColor: Colors.white,
      ),
      // Disesuaikan untuk menggunakan class Booking (sesuai BookingService Anda)
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD7FC64)),
            ); // accent-lime
          } else if (snapshot.hasError) {
            // Jika ada error (termasuk error autentikasi atau network)
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
                      'Gagal memuat data booking: ${snapshot.error.toString().replaceFirst('Future.error: ', '').replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _futureBookings =
                              _fetchBookings(); // Coba fetch ulang
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.grey,
                    size: 64,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Anda belum memiliki riwayat booking.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Opsional: tombol untuk ke halaman utama
                ],
              ),
            );
          } else {
            // Tampilkan daftar booking
            final bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    // Asumsi: field lapangan ada di class Booking dan memiliki property name
                    title: Text(
                      booking.lapangan.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF243153),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          // Asumsi: field totalPrice ada di class Booking
                          'Total Harga: Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(booking.totalPrice)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                // Asumsi: field statusBook ada di class Booking
                                color: _getStatusColor(
                                  booking.statusBook,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                booking.statusBook.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(booking.statusBook),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // Asumsi: field createdAt ada di class Booking
                          'Dibuat pada: ${DateFormat('dd MMM yyyy, HH:mm').format(booking.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          
                          builder: (context) => BookingDetailScreen(bookingId: booking.id),
                              
                        ),
                      ).then((_) {
                        // Refresh data saat kembali ke halaman ini
                        setState(() {
                          _futureBookings = _fetchBookings();
                        });
                      });
                    },
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
