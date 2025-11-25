import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/event/model/event_model.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntry event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final Color _primaryBlue = const Color(0xFF243153);
  final Color _accentGreen = const Color(0xFFD7FC64);
  final Color _cancelBackground = const Color.fromARGB(255, 244, 48, 61); 
  final Color _whiteText = Colors.white;

  // TODO: nanti variabel ini diambil dari backend
  bool isJoined = false; 

  @override
  Widget build(BuildContext context) {
    // ambil tinggi layar
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, 
      
      // pakai Stack untuk menumpuk widget
      body: Stack(
        children: [
          
          // gambar as header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35, // Tinggi sekitar 45% layar
            child: Stack(
              fit: StackFit.expand,
              children: [
                // foto Lapangan (Ganti dengan image_url dari event)
                Image.network(
                  widget.event.imageUrl.isNotEmpty 
                      ? widget.event.imageUrl 
                      : "https://via.placeholder.com/500x300", // Placeholder jika kosong
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),

                // add shadow di atas foto biar teks lebih terbaca
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    )
                  ),
                ),
                
                // button back
                Positioned(
                  top: 50,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // detail 
          Positioned(
            top: screenHeight * 0.25,
            left: 20,
            right: 20,
            bottom: 100, // sisakan space untuk tombol
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              // isi card bisa discroll (kalau isinya banyak)
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                   // nama event
                  Text(
                    widget.event.name,
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // info peserta
                  Row(
                    children: [
                      const Icon(Icons.people, color: Color.fromARGB(255, 219, 219, 219), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        "${widget.event.participantCount} / ${widget.event.maxParticipants} Peserta",
                        style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w700, fontSize:12),
                      ),

                      const Spacer(),

                      // badge status -> tersedia atau udah penuh
                      Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: widget.event.participantCount >= widget.event.maxParticipants 
                              ? Colors.red.withOpacity(0.2) 
                              : _accentGreen.withOpacity(0.5),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Text(
                           widget.event.participantCount >= widget.event.maxParticipants ? "Penuh" : "Tersedia",
                           style: TextStyle(
                             color: widget.event.participantCount >= widget.event.maxParticipants ? Colors.red : _primaryBlue,
                             fontWeight: FontWeight.bold,
                             fontSize: 12
                           ),
                         ),
                      )
                    ],
                  ),
                  
                  const Divider(height: 25),

                  // lokasi dan tanggal
                  _buildInfoRow(Icons.calendar_today, "${widget.event.startDate.day} - ${widget.event.startDate.month} - ${widget.event.startDate.year}"),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, widget.event.location),

                  const Divider(height: 25),

                  // Deskripsi
                  Text(
                    "Deskripsi",
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.event.description,
                    style: TextStyle(color: _primaryBlue, height: 1.5, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // button join atau leave event
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryBlue, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined ? _cancelBackground : _accentGreen, 
                  foregroundColor: isJoined ? _whiteText : _primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Dummy Logic Toggle
                  setState(() {
                    isJoined = !isJoined;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isJoined ? "Berhasil Join Event!" : "Berhasil Keluar dari Event"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  isJoined ? "Leave Event" : "Join Event Now",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper widget untuk susun baris info icon + teks
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: _primaryBlue, fontSize: 11),
          ),
        ),
      ],
    );
  }
}