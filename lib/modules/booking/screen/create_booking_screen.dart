import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart' as Lapangan; // Import package untuk otentikasi
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart' as Jadwal; // Import variabel pathWeb Anda
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
// dummy 
import 'booking_detail_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  final String lapanganId;

  // Constructor bisa menerima Lapangan object dari Home Page untuk info
  const CreateBookingScreen({Key? key, required this.lapanganId}) : super(key: key);

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late Future<Map<String, dynamic>> _futureScheduleData;
  late BookingService _service;
  final Set<String> _selectedJadwalIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mendapatkan instance CookieRequest dan membuat BookingService
    final request = Provider.of<CookieRequest>(context);
    _service = BookingService(request: request);
    _futureScheduleData = _service.fetchAvailableSchedules(widget.lapanganId);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }
  
  // Fungsi untuk memproses booking ke Django
  void _submitBooking() async {
    if (_selectedJadwalIds.isEmpty) {
      _showSnackBar('Pilih minimal satu jadwal.', isError: true);
      return;
    }

    try {
      final Map<String, dynamic> result = await _service.createBooking(
        widget.lapanganId, 
        _selectedJadwalIds.toList(),
      );
      
      final String bookingId = result['bookingId'];
      
      _showSnackBar('Booking berhasil dibuat! Lanjut ke Pembayaran.', isError: false);
      
      // Arahkan ke halaman detail booking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailScreen(bookingId: bookingId),
        ),
      );
      
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memastikan DateFormat dapat mengenali 'EEEE, d MMM' untuk bahasa Indonesia
    // Karena kita menggunakan locale 'id_ID' di NumberFormat, pastikan locale tersedia.
    Intl.defaultLocale = 'id_ID';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jadwal Booking'),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: const Color(0xFFD7FC64),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureScheduleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF243153)));
          } 
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.hasData) {
            final Lapangan.Datum lapangan = snapshot.data!['lapangan'];
            final List<Jadwal.Datum> jadwalList = snapshot.data!['jadwalList'];
            
            if (jadwalList.isEmpty) {
               return const Center(child: Text('Tidak ada jadwal tersedia dalam 3 hari ke depan.'));
            }
            
            final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

            return Column(
              children: [
                // Info Lapangan
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lapangan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243153))),
                      const SizedBox(height: 4),
                      Text('Harga/Jam: ${formatter.format(lapangan.price)}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                      const Text('Pilih slot waktu (max 3 hari dari sekarang)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
                // Daftar Jadwal
                Expanded(
                  child: ListView.builder(
                    itemCount: jadwalList.length,
                    itemBuilder: (context, index) {
                      final jadwal = jadwalList[index];
                      
                      final String formattedDate = DateFormat('EEEE, d MMM').format(jadwal.tanggal);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        color: Colors.white,
                        child: CheckboxListTile(
                          activeColor: const Color(0xFF243153),
                          title: Text('$formattedDate - ${jadwal.startMain} to ${jadwal.endMain}', style: const TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.w600)),
                          subtitle: Text(jadwal.isAvailable ? 'Tersedia' : 'Sudah Dipesan', style: TextStyle(color: jadwal.isAvailable ? Colors.green : Colors.red, fontSize: 12)),
                          value: _selectedJadwalIds.contains(jadwal.id),
                          onChanged: (bool? newValue) {
                            if (jadwal.isAvailable) {
                              setState(() {
                                if (newValue == true) {
                                  _selectedJadwalIds.add(jadwal.id);
                                } else {
                                  _selectedJadwalIds.remove(jadwal.id);
                                }
                              });
                            } // Hanya bisa diklik jika available
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer & Tombol Submit
                _buildFooter(lapangan),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _buildFooter(Lapangan.Datum lapangan) {
    final int subtotal = _selectedJadwalIds.length * lapangan.price;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jumlah Slot:', style: TextStyle(fontSize: 16, color: Color(0xFF243153))),
              Text('${_selectedJadwalIds.length} Jam', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF243153))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF243153))),
              Text(formatter.format(subtotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF243153))),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243153),
              foregroundColor: const Color(0xFFD7FC64),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
            ),
            child: const Text('Lanjut ke Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}