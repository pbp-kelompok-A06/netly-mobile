  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:pbp_django_auth/pbp_django_auth.dart';
  import 'package:provider/provider.dart';
  import 'package:netly_mobile/modules/booking/model/booking_model.dart';
  import 'package:netly_mobile/modules/booking/services/booking_services.dart';
  import 'package:netly_mobile/modules/booking/model/dummy_jadwal_lapangan_model.dart';

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
      print('Fetching booking detail for ID: ${widget.bookingId}');
      setState(() {
        _futureBooking = _service.fetchBookingDetail(widget.bookingId);
      });
    }

    void _showSnackBar(String message, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
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
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'LAKUKAN PEMBAYARAN KE REKENING 123-456-789 AN. NETLY-SPOTIPE',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Menerapkan views.py:complete_booking
                    await _service.completePayment(widget.bookingId);
                    _showSnackBar(
                      'Pembayaran berhasil dikonfirmasi!',
                      isError: false,
                    );
                    _fetchBookingDetail(); // Refresh data
                  } catch (e) {
                    _showSnackBar(e.toString(), isError: true);
                  }
                },
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFD7FC64),
                ),
                label: const Text('Konfirmasi Pembayaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF243153),
                  foregroundColor: const Color(0xFFD7FC64),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

            // Detail Booking
            _buildInfoRow(
              Icons.person_outline,
              'Player',
              booking.userFullname,
            ), // Perubahan di sini
            _buildInfoRow(
              Icons.date_range,
              'Dibuat',
              DateFormat('d MMM y, HH:mm').format(booking.createdAt),
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Harga/Jam',
              formatter.format(booking.lapangan.price),
            ),

            const SizedBox(height: 20),

            // Jadwal Dipesan
            const Text(
              'Jadwal Dipilih:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF243153),
              ),
            ),
            const SizedBox(height: 10),
            ...booking.jadwal.map((j) => _buildScheduleItem(j)).toList(),

            const Divider(height: 30, thickness: 2, color: Colors.grey),

            // Total Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL HARGA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243153),
                  ),
                ),
                Text(
                  formatter.format(booking.totalPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD7FC64),
                    backgroundColor: Color(0xFF243153),
                  ),
                ),
              ],
            ),

            // Tombol Aksi (Konfirmasi Pembayaran)
            actionButton,
          ],
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
                      color: Color(0xFF243153),
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

    Widget _buildScheduleItem(Jadwal jadwal) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Color(0xFF243153)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${DateFormat('d MMM y').format(jadwal.tanggal)} | ${jadwal.startMain} - ${jadwal.endMain}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF243153),
                ),
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
                child: Text(
                  'Gagal memuat detail booking: ${snapshot.error}',
                  textAlign: TextAlign.center,
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

  // JANGAN LUPA TAMBAHIN DELETE DARI SIDE ADMIN YA COYY 
