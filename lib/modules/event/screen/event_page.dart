import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:netly_mobile/modules/event/model/event_model.dart';
import 'package:netly_mobile/modules/event/widgets/event_card.dart';
import 'package:netly_mobile/modules/event/screen/form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final Color _primaryBlue = const Color(0xFF243153);
  final Color _accentGreen = const Color(0xFFD7FC64); 
  final Color _inactiveTrack = const Color(0xFFE0E0E0); 
  final Color _inactiveText = const Color(0xFF757575);  // abu abu text kalau button inactive

  // sorting: true = ascending (terlama -> terbaru), false = descending
  bool _isAscending = false;

  Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/event/show_events_flutter');

    // convert Json dari django ke List<EventEntry>
    var data = response;
    List<EventEntry> listEvents = [];
    for (var things in data) {
      if ( things != null) {
        listEvents.add(EventEntry.fromJson(things));
      }
    }

    // logic untuk sorting
    if (_isAscending) {
      listEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
    } else {
      listEvents.sort((b, a) => a.startDate.compareTo(b.startDate));
    }

    return listEvents;
  }

  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); // Akses request

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Events', style: TextStyle(
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF243153),
        elevation: 0,
        surfaceTintColor: Colors.white,
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

          // tampilin card event pakai FutureBuilder
          Expanded(
            child: FutureBuilder(
              future: fetchEvents(request), // panggil fungsi fetch
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada event."));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => EventCard(event: snapshot.data![index]),
                    );
                  }
                }
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