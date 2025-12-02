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
  final Color _primaryBlue = const Color(0xFF243153); // Warna Utama (Navy)
  final Color _accentGreen = const Color(0xFFD7FC64); // Warna Aksen (Lime)
  final Color _inactiveTrack = const Color(0xFFE0E0E0); // Abu-abu background track
  final Color _inactiveText = const Color(0xFF757575);  // abu abu text kalau button inactive

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
      name: "sparring netly",
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
          
          // section untuk filter
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              "Sort Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryBlue,
              ),
            ),
          ),

          // untuk toggle button filter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(4.0), 
            height: 50,
            decoration: BoxDecoration(
              color: _inactiveTrack, 
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                // button kiri untuk descending (latest ke earliest)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAscending = false; 
                        _sortEvents();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200), // efek animasi smooth
                      decoration: BoxDecoration(
                        color: !_isAscending ? _primaryBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Latest \u2192 Earliest", 
                        style: TextStyle(
                          // set warna text antara dia active dan ga active
                          color: !_isAscending ? _accentGreen : _inactiveText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),

                // button kanan untuk earliest ke latest
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAscending = true; 
                        _sortEvents();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _isAscending ? _primaryBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Earliest \u2192 Latest",
                        style: TextStyle(
                          color: _isAscending ? _accentGreen : _inactiveText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), 

          // tampilin card event
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