import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final dynamic bookingId;
  const BookingDetailScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Future<Booking> _futureBooking;
  late BookingService _service;
  
  
  bool _isDataChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = Provider.of<CookieRequest>(context);
    _service = BookingService(request: request);
    _fetchBookingDetail();
  }

  void _fetchBookingDetail() {
    setState(() {
      _futureBooking = _service.fetchBookingDetail(widget.bookingId.toString(), _service.request);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
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

  Future<void> _onCompletePayment() async {
    try {
      await _service.completePayment(widget.bookingId.toString());
      
      
      setState(() {
        _isDataChanged = true;
      });
      
      _showSnackBar('Pembayaran berhasil dikonfirmasi!', isError: false);
      _fetchBookingDetail();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Widget _buildDetail(Booking booking) {
    final bool isPending = booking.statusBook == 'pending';
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    Color statusColor;
    Color statusBgColor;

    switch (booking.statusBook.toLowerCase()) {
      case 'pending':
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade100;
        break;
      case 'completed':
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade100;
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade200;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.lapangan.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF243153)),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(booking.statusBook.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            backgroundColor: statusBgColor,
          ),
          const Divider(height: 30, thickness: 1),
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
                  _buildInfoRow(Icons.person_outline, 'Dipesan Oleh', booking.userFullname),
                  _buildInfoRow(Icons.date_range, 'Waktu Transaksi', DateFormat('d MMM y, HH:mm').format(booking.createdAt)),
                  _buildInfoRow(Icons.attach_money, 'Harga/Jam', formatter.format(booking.lapangan.price)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF243153),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD7FC64).withOpacity(0.3), spreadRadius: 2, blurRadius: 10),
                ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('TOTAL HARGA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                Text(formatter.format(booking.totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFD7FC64))),
              ],
            ),
          ),
          if (isPending)
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade300)),
                    child: const Text('LAKUKAN PEMBAYARAN KE REKENING 123-456-789 AN. NETLY-SPOTIPE', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _onCompletePayment,
                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF243153)),
                    label: const Text('Konfirmasi Pembayaran'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7FC64),
                      foregroundColor: const Color(0xFF243153),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF243153), letterSpacing: 0.5));
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
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
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
      decoration: BoxDecoration(color: const Color(0xFFD7FC64).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7FC64).withOpacity(0.5))),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 20, color: Color(0xFF243153)),
          const SizedBox(width: 12),
          Expanded(child: Text(DateFormat('d MMM y').format(jadwal.tanggal).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF243153)), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('${jadwal.startMain}:00 - ${jadwal.endMain}:00', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF243153))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop && _isDataChanged) {
          
          
          
          
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Booking'),
          backgroundColor: const Color(0xFF243153),
          foregroundColor: const Color(0xFFD7FC64),
          elevation: 0,
          leading: BackButton(
            onPressed: () => Navigator.pop(context, _isDataChanged),
          ),
        ),
        body: FutureBuilder<Booking>(
          future: _futureBooking,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF243153)));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Gagal memuat: ${snapshot.error.toString()}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Data tidak ditemukan.'));
            } else {
              return _buildDetail(snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}