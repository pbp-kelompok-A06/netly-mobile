import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/screen/booking_detail_screen.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
import 'package:netly_mobile/utils/path_web.dart'; // Diperlukan untuk BookingService
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
  // State untuk data booking
  late Future<List<Booking>> _futureBookings;

  // State baru untuk status Admin
  bool _isAdmin = false;
  bool _isAdminChecked = false; // Untuk melacak apakah cek admin sudah selesai

  @override
  void initState() {
    super.initState();
    // Mulai pengecekan status Admin
    _checkAdminStatus();
    // Mulai fetching data booking
    _futureBookings = _fetchBookings();
  }

  // Fungsi baru untuk memuat status admin
  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    final service = BookingService(request: request);

    try {
      final adminInfo = await service.getAdminInfo(request);

      if (mounted) {
        setState(() {
          _isAdmin = adminInfo['is_admin'] == true;
          _isAdminChecked = true; // Status admin sudah diketahui
        });
        print('Admin Status Check Complete: isAdmin=$_isAdmin');
      }
    } catch (e) {
      print('Failed to check admin status: $e');
      if (mounted) {
        // Asumsikan non-admin jika gagal, tapi tetap tandai sudah selesai dicek
        setState(() {
          _isAdmin = false;
          _isAdminChecked = true;
        });
      }
    }
  }

  // Fungsi untuk memuat data booking
  Future<List<Booking>> _fetchBookings() async {
    final request = context.read<CookieRequest>();
    final service = BookingService(request: request);

    try {
      return await service.fetchAllBookings(request);
    } catch (e) {
      print('Failed to load bookings via Service: $e');

      if (context.mounted) {
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
        return Colors.green.shade700;
      case 'failed':
        return Colors.red.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'failed':
        return Colors.red.shade100;
      case 'pending':
        return Colors.orange.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika status admin belum diketahui
    if (!_isAdminChecked) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            title: Text(
              'My Bookings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF243153),
            foregroundColor: Colors.white,
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD7FC64)),
        ),
      );
    }

    // Setelah status admin diketahui, tampilkan FutureBuilder untuk data booking
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243153), // primary-dark
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD7FC64)),
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
                      'Gagal memuat data booking: ${snapshot.error.toString().replaceFirst('Future.error: ', '').replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _futureBookings = _fetchBookings(); // Coba fetch ulang
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
                ],
              ),
            );
          } else {
            // Tampilkan daftar booking
            final bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                
                // Tentukan layar detail yang akan dinavigasi
                final Widget detailScreen = _isAdmin
                    ? BookingDetailAdminScreen(
                        bookingId: booking.id,
                      ) // Detail untuk Admin
                    : BookingDetailScreen(
                        bookingId: booking.id,
                      ); // Detail untuk User Biasa
                
                return GestureDetector(
                  onTap: () {
                    // Logika navigasi menggunakan .then() untuk refresh data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => detailScreen,
                      ),
                    ).then((result) {
                      // Refresh data saat kembali ke halaman ini
                      setState(() {
                        _futureBookings = _fetchBookings();
                      });
                      
                      // Tampilkan SnackBar jika hasil kembali adalah true (berhasil dihapus dari detail admin screen)
                      // Catatan: Ini hanya akan berfungsi jika Anda menghapus pushAndRemoveUntil di detail admin screen,
                      // tapi karena kita menggunakan pushAndRemoveUntil di admin screen, SnackBar dihandle di sana.
                      // Namun, kita tetap melakukan refresh data di sini.
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: _getStatusColor(booking.statusBook).withOpacity(0.5),
                        width: 1.0,
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Bagian Atas: Lapangan dan Status ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                booking.lapangan.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF243153),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(booking.statusBook),
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
                        const Divider(height: 20, thickness: 0.5),

                        // --- Bagian Detail: Harga dan Waktu ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Harga',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(booking.totalPrice)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Dibuat pada',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(booking.createdAt),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        // --- Tombol Detail ---
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lihat Detail >',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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