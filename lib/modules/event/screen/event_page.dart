import 'package:flutter/material.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart'; 
// import 'package:provider/provider.dart'; 

import 'package:netly_mobile/modules/event/model/event_model.dart';
import 'package:netly_mobile/modules/event/widgets/event_card.dart';
import 'package:netly_mobile/modules/event/screen/form.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final Color _primaryBlue = const Color(0xFF243153);
  final Color _accentGreen = const Color(0xFFD7FC64);
  final Color _redFilter = const Color(0xFFC01B2E); 

  // sorting: true = ascending (terlama -> terbaru), false = descending
  bool _isAscending = true;

  // dummy data untuk cek tampilan
  final List<EventEntry> dummyEvents = [
    EventEntry(
      id: "1",
      name: "Mabar Badminton Ceria",
      description: "Main bareng santai untuk pemula.",
      location: "GOR Cempaka Putih",
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      imageUrl: "https://via.placeholder.com/150", 
      maxParticipants: 10,
      participantCount: 5,
    ),
    EventEntry(
      id: "2",
      name: "Turnamen Netly Cup",
      description: "Turnamen serius hadiah raket.",
      location: "GOR Ragunan",
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      imageUrl: "https://via.placeholder.com/150", 
      maxParticipants: 20,
      participantCount: 20,
    ),
    EventEntry(
      id: "3",
      name: "Latihan Rutin Pagi",
      description: "Latihan fisik dan teknik dasar.",
      location: "GOR Sumantri",
      startDate: DateTime.now().add(const Duration(days: 1)), // Besok (Paling cepat)
      endDate: DateTime.now().add(const Duration(days: 1)),
      imageUrl: "https://via.placeholder.com/150", 
      maxParticipants: 8,
      participantCount: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // default sortnya ascending
    _sortEvents();
  }

  // untuk handle sorting event berdasarkan tanggal
  void _sortEvents() {
    setState(() {
      if (_isAscending) {
        // ascending: tanggal kecil (lama) ke besar (baru)
        dummyEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
      } else {
        // descending: tanggal besar (baru) ke kecil (lama)
        dummyEvents.sort((b, a) => a.startDate.compareTo(b.startDate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events', style: TextStyle(
          fontWeight: FontWeight.bold,
        )),
        foregroundColor: const Color(0xFF243153),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // button untuk filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                // status sorting berubah saat diklik
                setState(() {
                  _isAscending = !_isAscending;
                  _sortEvents(); // panggil fungsi sort 
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isAscending ? "Urutan: Terlama ke Terbaru" : "Urutan: Terbaru ke Terlama"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _redFilter,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // supaya lebar container ngikutin isi
                  children: [
                    Text(
                      "Date: ${_isAscending ? 'Ascending' : 'Descending'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // pake expanded karena listview butuh parent dengan ukuran terbatas
          Expanded( 
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: dummyEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: dummyEvents[index]);
              },
            ),
          ),
        ],
      ),

      // Add New Event button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const EventFormPage();
            },
          );
        },
        label: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: _primaryBlue,
        foregroundColor: _accentGreen,
      ),
    );
  }
}