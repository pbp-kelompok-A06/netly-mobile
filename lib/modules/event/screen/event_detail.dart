import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/event/model/event_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
  final Color _disabledGrey = Colors.grey;

  // TODO: ganti isAdmin nanti pake data dari backend
  final bool isAdmin = true;
  bool isJoined = false;
  late int currentParticipants; 

  @override
  void initState() {
    super.initState();
    // status awal join (default false)
    isJoined = widget.event.isJoined; 
    currentParticipants = widget.event.participantCount;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // ambil tinggi layar
    final double screenHeight = MediaQuery.of(context).size.height;
    bool isFull = currentParticipants >= widget.event.maxParticipants;
    // tombol mati kalau udah penuh dan usernya belum join
    bool isButtonDisabled = isFull && !isJoined;

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
                // foto lapangan (Ganti dengan image_url dari event)
                Image.network(
                  widget.event.imageUrl.isNotEmpty 
                      ? widget.event.imageUrl 
                      : "https://via.placeholder.com/500x300", // placeholder kalo kosong
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
                        "$currentParticipants / ${widget.event.maxParticipants} Peserta",
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.event.description,
                    style: TextStyle(color: _primaryBlue, height: 1.5, fontSize: 11),
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
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -7))],
              ),
              child: isAdmin 
                ? _buildAdminButtons()  // show button buat admin
                : _buildUserButton(isButtonDisabled, request), // show button buat non-admin user
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        // edit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: _accentGreen, // Teks Lime Green
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () {
              // TODO: Arahkan ke halaman Edit Event
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masuk ke mode Edit (Soon)")));
            },
            child: const Text("Edit Event", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 12), 
        
        // delete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _cancelBackground,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () {
              // TODO: Tampilkan Dialog Konfirmasi Delete
              _showDeleteConfirmation(context);
            },
            child: const Text("Delete Event", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // dialog delete confirmation
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                // TODO: Panggil API Delete ke Django di sini
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted (Mock)"), backgroundColor: Colors.red));
                Navigator.pop(context); // Kembali ke halaman list event
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // button untuk user non admin -> join or leave event
  Widget _buildUserButton(bool isButtonDisabled, CookieRequest request) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonDisabled 
              ? _disabledGrey 
              : (isJoined ? _cancelBackground : _primaryBlue), // Join pakai Navy, Leave pakai Merah
          foregroundColor: isButtonDisabled 
              ? Colors.white 
              : (isJoined ? _whiteText : _accentGreen), // Teks Join pakai Lime
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        onPressed: isButtonDisabled 
            ? null 
            : () async {
                final response = await request.postJson(
                  "http://localhost:8000/event/join-flutter/${widget.event.id}/",
                  jsonEncode({}),
                );
                // ... logic handle response (sama seperti sebelumnya) ...
                if (context.mounted) {
                   if (response['status'] == 'success') {
                      setState(() {
                        if (response['action'] == 'join') {
                          isJoined = true;
                          currentParticipants++;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Join!"), backgroundColor: Colors.green));
                        } else {
                          isJoined = false;
                          currentParticipants--;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Leave!"), backgroundColor: Colors.red));
                        }
                      });
                   }
                }
              },
        child: Text(
          isButtonDisabled 
              ? "Kuota Penuh" 
              : (isJoined ? "Leave Event" : "Join Event Now"),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
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