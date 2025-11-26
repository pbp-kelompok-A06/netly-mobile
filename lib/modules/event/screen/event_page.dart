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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events', style: TextStyle(
          fontWeight: FontWeight.bold,
        )),
        foregroundColor: const Color(0xFF243153),
      ),
      
      body: ListView.builder(
        itemCount: dummyEvents.length,
        itemBuilder: (context, index) {
          return EventCard(event: dummyEvents[index]);
        },
      ),

      // Add New Event Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //  showDialog -> buat pop up form add event (jadi ga pindah halaman)
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const EventFormPage();
            },
          );
        },
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: const Color(0xFFD7FC64),
      ),
    );
  }
}