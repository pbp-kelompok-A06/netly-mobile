import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/event/model/event_model.dart';
import 'package:netly_mobile/modules/event/screen/form.dart';
import 'package:netly_mobile/utils/path_web.dart';
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

  bool isJoined = false;
  late int currentParticipants; 
  bool hasChanged = false;

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

    // role checking
    String role = request.jsonData['userData']?['role'] ?? "user";
    bool isAdmin = role == 'admin';

    double contentBottomPadding = isAdmin ? 180.0 : 100.0;

    // ambil tinggi layar
    final double screenHeight = MediaQuery.of(context).size.height;
    bool isFull = currentParticipants >= widget.event.maxParticipants;
    // untuk cek apakah suatu event udah lewat atau belum
    bool isPastEvent = widget.event.endDate.isBefore(DateTime.now());
    // tombol mati kalau udah penuh dan usernya belum join
    bool isButtonDisabled = (isFull && !isJoined) || isPastEvent;

    // untuk teks di button sesuai kondisi
    String buttonText;
      if (isPastEvent) {
        buttonText = "Event Ended";
      } else if (isFull && !isJoined) {
        buttonText = "Quota Full";
      } else {
        buttonText = isJoined ? "Leave Event" : "Join Event Now";
      }

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
            height: screenHeight * 0.35, // tinggi sekitar 45% layar
            child: Stack(
              fit: StackFit.expand,
              children: [
                // foto lapangan 
                Image.network(
                  widget.event.imageUrl, // URL dari event
                  fit: BoxFit.cover,     // agar gambar memenuhi area
                  
                  // Builder untuk menangani status loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200], // background abu-abu saat loading
                      child: Center(
                        child: CircularProgressIndicator(
                          // menampilkan progress download jika ada infonya
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  
                  // builder untuk menangani error (URL rusak/kosong)
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        // Menggunakan gambar default dari assets
                        image: AssetImage('assets/images/default.jpg'), 
                        fit: BoxFit.cover,
                      ),
                    ),
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
                    onTap: () => Navigator.pop(context, hasChanged),
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
            bottom: contentBottomPadding,
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
                           color: isPastEvent 
                              ? Colors.grey.withOpacity(0.3) // abu-abu kalau lewat
                              : (isFull ? Colors.red.withOpacity(0.1) : _accentGreen.withOpacity(0.5)),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Text(
                           isPastEvent ? "Ended" : (isFull ? "Full" : "Open"),
                           style: TextStyle(
                             color: isPastEvent ? Colors.black54 : (isFull ? Colors.red : _primaryBlue),
                             fontWeight: FontWeight.bold, fontSize: 12
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
                ? _buildAdminButtons(context, request) // show button buat admin
                : _buildUserButton(context, request, isButtonDisabled, buttonText), // show button buat non-admin user
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButtons(BuildContext context, CookieRequest request) {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        // edit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: _accentGreen, 
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () async {
              // pakai form tapi mode edit
              final result = await showDialog(
                context: context,
                builder: (context) => EventFormPage(event: widget.event),
              );

              // kalau update berhasil, refresh halaman supaya automatically update datanya
              if (result == true) {
                if (context.mounted) {
                   Navigator.pop(context, true); 
                }
              }
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
    final request = context.read<CookieRequest>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () async {
                // close dialog konfirmasi
                Navigator.pop(context); 
                
                // use delete_event_ajax
                final response = await request.postJson(
                  "$pathWeb/event/delete-flutter/${widget.event.id}/", 
                  jsonEncode({}),
                );

                if (context.mounted) {
                  if (response['status'] == 'success') {
                    // kembali ke halaman list event dan kirim sinyal refresh
                    Navigator.pop(context, true); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Event deleted successfully"), backgroundColor: Colors.red),
                    );
                  } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? "Failed to delete")),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // button untuk user non admin -> join or leave event
  Widget _buildUserButton(BuildContext context, CookieRequest request, bool isButtonDisabled, String text){
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonDisabled 
              ? _disabledGrey 
              : (isJoined ? _cancelBackground : _primaryBlue), 
          foregroundColor: isButtonDisabled 
              ? Colors.white 
              : (isJoined ? _whiteText : _accentGreen), 
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        onPressed: isButtonDisabled && !isJoined
            ? null 
            : () async {
                final response = await request.postJson(
                  "$pathWeb/event/join-flutter/${widget.event.id}/",
                  jsonEncode({}),
                );
                if (context.mounted) {
                   if (response['status'] == 'success') {
                      setState(() {
                        hasChanged = true;
                        if (response['action'] == 'join') {
                          isJoined = true;
                          currentParticipants++;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Join!"), backgroundColor: Colors.green));
                        } else {
                          isJoined = false;
                          if (currentParticipants > 0) {
                            currentParticipants--;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Leave!"), backgroundColor: Colors.red));
                        }
                      });
                   }
                }
              },
        child: Text(
          text,
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