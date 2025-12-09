import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final bookingId;
  const BookingDetailScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Future<Booking> _futureBooking;
  late BookingService _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mendapatkan instance CookieRequest dan membuat BookingService
    final request = Provider.of<CookieRequest>(context);
    _service = BookingService(request: request);
    _fetchBookingDetail();
  }

  void _fetchBookingDetail() {
    
    setState(() {
      _futureBooking = _service.fetchBookingDetail(widget.bookingId, _service.request);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Memastikan SnackBar hanya ditampilkan jika widget masih mounted
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDetail(Booking booking) {
    final bool isPending = booking.statusBook == 'pending';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    Color statusColor;
    Color statusBgColor;

    switch (booking.statusBook) {
      case 'pending':
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade100;
        break;
      case 'completed':
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade100;
        break;
      case 'failed':
      default:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade200;
        break;
    }

    // Logic Tombol Konfirmasi Pembayaran
    Widget actionButton = const SizedBox.shrink();
    if (isPending) {
      actionButton = Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300)
              ),
              child: Text(
                'LAKUKAN PEMBAYARAN KE REKENING 123-456-789 AN. NETLY-SPOTIPE',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Menerapkan views.py:complete_booking
                  await _service.completePayment(widget.bookingId);
                  _showSnackBar('Pembayaran berhasil dikonfirmasi!', isError: false);
                  _fetchBookingDetail(); // Refresh data
                } catch (e) {
                  _showSnackBar(e.toString(), isError: true);
                }
              },
              icon: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF243153), // Ganti warna ikon menjadi biru tua
              ),
              label: const Text('Konfirmasi Pembayaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7FC64), // Aksen Neon Hijau
                foregroundColor: const Color(0xFF243153), // Text biru tua
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Lapangan
          Text(
            booking.lapangan.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243153),
            ),
          ),
          const SizedBox(height: 8),

          // Badge Status
          Chip(
            label: Text(
              booking.statusBook.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: statusBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          const Divider(height: 30, thickness: 1),

          // --- CARD 1: DETAIL PENGGUNA & WAKTU ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Detail Transaksi'),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Dipesan Oleh',
                    booking.userFullname,
                  ),
                  _buildInfoRow(
                    Icons.date_range,
                    'Waktu Transaksi',
                    DateFormat('d MMM y, HH:mm').format(booking.createdAt),
                  ),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Harga/Jam',
                    formatter.format(booking.lapangan.price),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- CARD 2: JADWAL DIPESAN ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Jadwal Dipesan'),
                  const SizedBox(height: 10),
                  if (booking.jadwal.isEmpty)
                    const Text('Tidak ada slot jadwal yang terkait.', style: TextStyle(color: Colors.grey)),
                  ...booking.jadwal.map((j) => _buildScheduleItem(j)).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          // --- TOTAL HARGA (Highlight) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF243153), // Latar belakang biru tua
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                 BoxShadow(
                  color: const Color(0xFFD7FC64).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL HARGA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formatter.format(booking.totalPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD7FC64), // Aksen Neon Hijau
                  ),
                ),
              ],
            ),
          ),

          // Tombol Aksi (Konfirmasi Pembayaran)
          actionButton,
        ],
      ),
    );
  }

  // Widget baru untuk header bagian
  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF243153),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF243153), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(JadwalData jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD7FC64).withOpacity(0.1), // Latar belakang aksen ringan
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7FC64).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 20, color: Color(0xFF243153)),
          const SizedBox(width: 12),
          Text(
            DateFormat('d MMM y').format(jadwal.tanggal)
                .toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF243153),
            ),
          ),
          const Spacer(),
          Text(
            '${jadwal.startMain}:00 - ${jadwal.endMain}:00',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF243153),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: const Color(0xFFD7FC64),
        elevation: 0,
      ),
      body: FutureBuilder<Booking>(
        future: _futureBooking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF243153)),
            );
          } else if (snapshot.hasError) {
            print("📌 STACKTRACE: ${snapshot.stackTrace}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gagal memuat detail booking: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Detail Booking tidak ditemukan.'));
          } else {
            return _buildDetail(snapshot.data!);
          }
        },
      ),
    );
  }
}