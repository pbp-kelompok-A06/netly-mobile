import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart' as Lapangan;
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart' ;
import 'package:netly_mobile/modules/booking/services/booking_services.dart';
// dummy 
import 'booking_detail_screen.dart';

// --- Palet Warna Modern ---
const Color kPrimaryColor = Color(0xFF243153); // Dark Blue/Grey
const Color kAccentColor = Color(0xFFD7FC64); // Lime Green
const Color kSuccessColor = Color(0xFF4CAF50); // Green for Available
const Color kUnavailableColor = Color(0xFFF44336); // Red for Unavailable

class CreateBookingScreen extends StatefulWidget {
 
 final String lapanganId;

 const CreateBookingScreen({Key? key, required this.lapanganId}) : super(key: key);

 @override
 State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
 late Future<Map<String, dynamic>> _futureScheduleData;
 late BookingService _service;
 final Set<String> _selectedJadwalIds = {};

@override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

 @override
 void didChangeDependencies() {
  super.didChangeDependencies();
  final request = Provider.of<CookieRequest>(context);
  _service = BookingService(request: request);
  _futureScheduleData = _service.fetchAvailableSchedules(widget.lapanganId);
 }

 void _showSnackBar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red.shade600 : kSuccessColor,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   ),
  );
 }
 
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
   
   Navigator.pushReplacement(
    context,
    MaterialPageRoute(
     builder: (context) => BookingDetailScreen(bookingId: bookingId),
    ),
   );
   
  } catch (e) {
   print("Error saat submit booking: $e");
   _showSnackBar(e.toString(), isError: true);
  }
 }

 @override
 Widget build(BuildContext context) {
  Intl.defaultLocale = 'id_ID';

  return Scaffold(
   backgroundColor: Colors.grey.shade50,
   appBar: AppBar(
    title: const Text('Pilih Jadwal Booking'),
    backgroundColor: kPrimaryColor,
    foregroundColor: kAccentColor,
    elevation: 0,
   ),
   body: FutureBuilder<Map<String, dynamic>>(
    future: _futureScheduleData,
    builder: (context, snapshot) {
     if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
     } 
     
     if (snapshot.hasError) {
      return Center(child: Text('Gagal memuat data: ${snapshot.error}', textAlign: TextAlign.center));
     }
     
     if (snapshot.hasData) {
      final Lapangan.Datum lapangan = snapshot.data!['lapangan'];
      final List<JadwalData> jadwalList = snapshot.data!['jadwalList'];
      
      if (jadwalList.isEmpty) {
       return Center(
         child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
           'Tidak ada jadwal tersedia dalam 2 hari ke depan untuk lapangan ${lapangan.name}.', 
           textAlign: TextAlign.center,
           style: TextStyle(color: kPrimaryColor.withOpacity(0.7)),
          ),
         ),
       );
      }
      
      return Column(
       children: [
        _buildLapanganInfoCard(lapangan),
        
        // Daftar Jadwal
        Expanded(
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
           padding: const EdgeInsets.only(top: 10, bottom: 80), // Padding untuk menghindari footer
           itemCount: jadwalList.length,
           itemBuilder: (context, index) {
            final jadwal = jadwalList[index];
            return _buildScheduleTile(jadwal);
           },
          ),
),
),

],
);
}
return const SizedBox.shrink();
},
),
   bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
    future: _futureScheduleData,
    builder: (context, snapshot) {
     if (snapshot.hasData) {
      final Lapangan.Datum lapangan = snapshot.data!['lapangan'];
      return _buildFooter(lapangan);
     }
     return const SizedBox.shrink();
    },
   ),
  );
 }

 Widget _buildLapanganInfoCard(Lapangan.Datum lapangan) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  return Card(
   margin: const EdgeInsets.all(16.0),
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
   elevation: 4,
   child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      Text(
       lapangan.name, 
       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor),
      ),
      const SizedBox(height: 8),
      Divider(color: Colors.grey.shade300, height: 1),
      const SizedBox(height: 8),
      Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
        const Text('Harga Per Jam:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(
         formatter.format(lapangan.price), 
         style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)
        ),
       ],
      ),
      const SizedBox(height: 12),
      const Text(
       'Pilih slot waktu yang tersedia (maksimal 3 hari dari sekarang)', 
       style: TextStyle(color: Colors.grey, fontSize: 13)
      ),
     ],
    ),
   ),
  );
 }

 Widget _buildScheduleTile(JadwalData jadwal) {
  final bool isSelected = _selectedJadwalIds.contains(jadwal.id);
  final bool isAvailable = jadwal.isAvailable;
  final String formattedDate = DateFormat('EEEE, d MMM', 'id_ID').format(jadwal.tanggal);
  final String timeSlot = '${jadwal.startMain} - ${jadwal.endMain}';

  return Padding(
   padding: const EdgeInsets.only(bottom: 8.0),
   child: Opacity(
    opacity: isAvailable ? 1.0 : 0.6,
    child: Card(
     color: isSelected ? kAccentColor.withOpacity(0.9) : Colors.white,
     elevation: isSelected ? 3 : 1,
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(
       color: isSelected ? kPrimaryColor : Colors.grey.shade200, 
       width: isSelected ? 2 : 1
      )
     ),
     child: InkWell(
      onTap: () {
       if (isAvailable) {
        setState(() {
         if (isSelected) {
          _selectedJadwalIds.remove(jadwal.id);
         } else {
          _selectedJadwalIds.add(jadwal.id);
         }
        });
       }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
       padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
       child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
            formattedDate, 
            style: TextStyle(
             color: isSelected ? kPrimaryColor : kPrimaryColor, 
             fontWeight: FontWeight.bold
            ),
           ),
           const SizedBox(height: 4),
           Text(
            timeSlot, 
            style: TextStyle(
             color: isSelected ? kPrimaryColor.withOpacity(0.8) : Colors.grey.shade700, 
             fontSize: 14
            ),
           ),
          ],
         ),
         
         Row(
          children: [
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
             color: isAvailable ? kSuccessColor.withOpacity(0.1) : kUnavailableColor.withOpacity(0.1),
             borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
             isAvailable ? 'Tersedia' : 'Dipesan', 
             style: TextStyle(
              color: isAvailable ? kSuccessColor : kUnavailableColor, 
              fontSize: 12,
              fontWeight: FontWeight.w600
             )
            ),
           ),
           const SizedBox(width: 8),
           Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? kPrimaryColor : Colors.grey.shade400,
           ),
          ],
         )
        ],
       ),
      ),
     ),
    ),
   ),
  );
 }
 
 Widget _buildFooter(Lapangan.Datum lapangan) {
  final int subtotal = _selectedJadwalIds.length * lapangan.price;
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final bool isButtonEnabled = _selectedJadwalIds.isNotEmpty;

  return Container(
   padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
   decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
     topLeft: Radius.circular(20), 
     topRight: Radius.circular(20)
    ),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 2)]
   ),
   child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       const Text(
        'Jumlah Slot Dipilih:', 
        style: TextStyle(fontSize: 15, color: kPrimaryColor),
       ),
       Text(
        '${_selectedJadwalIds.length} Jam', 
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor),
       ),
      ],
     ),
     const SizedBox(height: 12),
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       const Text(
        'Total Pembayaran:', 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
       ),
       Text(
        formatter.format(subtotal), 
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPrimaryColor),
       ),
      ],
     ),
     const SizedBox(height: 16),
     ElevatedButton(
      onPressed: isButtonEnabled ? _submitBooking : null,
      style: ElevatedButton.styleFrom(
       backgroundColor: kPrimaryColor,
       foregroundColor: kAccentColor,
       disabledBackgroundColor: kPrimaryColor.withOpacity(0.4),
       disabledForegroundColor: kAccentColor.withOpacity(0.6),
       padding: const EdgeInsets.symmetric(vertical: 16),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       elevation: 6,
      ),
      child: const Text('Lanjut ke Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
     ),
    ],
   ),
  );
 }
}