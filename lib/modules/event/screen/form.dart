import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/event/model/event_model.dart'; // Pastikan import model

class EventFormPage extends StatefulWidget {
  final EventEntry? event; // Parameter opsional: Kalau ada isinya berarti mode EDIT

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = "";
  String _description = "";
  String _location = "";
  String _imageUrl = "";
  int _maxParticipants = 0;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // cek mode, kalo edit -> widget.event tidak null
    if (widget.event != null) {
      // isi form dengan data lama
      _name = widget.event!.name;
      _description = widget.event!.description;
      _location = widget.event!.location;
      _imageUrl = widget.event!.imageUrl;
      _maxParticipants = widget.event!.maxParticipants;

      // format tanggal ke string YYYY-MM-DD
      _startDateController.text = widget.event!.startDate.toString().substring(0, 10);
      _endDateController.text = widget.event!.endDate.toString().substring(0, 10);
    } else {
      // kalau create -> isi tanggal hari ini
      _startDateController.text = DateTime.now().toString().substring(0, 10); 
      _endDateController.text = DateTime.now().toString().substring(0, 10);
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // judul form sesuai mode
    final String title = widget.event != null ? "Edit Event" : "Create New Event";
    final String buttonText = widget.event != null ? "Update" : "Save";

    return AlertDialog(
      title: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF243153)),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      scrollable: true,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // name
                TextFormField(
                  initialValue: _name, // pre-fill value
                  decoration: InputDecoration(
                    labelText: "Event Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() => _name = value),
                  validator: (value) => value == null || value.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 12),
  
                // location
                TextFormField(
                  initialValue: _location,
                  decoration: InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() => _location = value),
                  validator: (value) => value == null || value.isEmpty ? "Location cannot be empty" : null,
                ),
                const SizedBox(height: 12),

                // Tanggal (Row)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Start Date",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onTap: () => _selectDate(context, _startDateController),
                      ),
                    ),
                   
                    const SizedBox(width: 8),

                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "End Date",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onTap: () => _selectDate(context, _endDateController),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
  
                // max participants
                TextFormField(
                  initialValue: _maxParticipants > 0 ? _maxParticipants.toString() : "",
                  decoration: InputDecoration(
                    labelText: "Max Participants",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => _maxParticipants = int.tryParse(value) ?? 0),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Cannot be empty";
                    if (int.tryParse(value) == null) return "Must be a number";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
  
                // image URL
                TextFormField(
                  initialValue: _imageUrl,
                  decoration: InputDecoration(
                    labelText: "Image URL",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() => _imageUrl = value),
                ),
                const SizedBox(height: 12),
  
                // Description
                TextFormField(
                  initialValue: _description,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() => _description = value),
                  validator: (value) => value == null || value.isEmpty ? "Description cannot be empty" : null,
                ),
              ],
            ),
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF243153),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // untuk tentukan endpoint antara edit atau create
              String url;
              if (widget.event != null) {
                // endpoint edit
                url = "http://localhost:8000/event/edit-flutter/${widget.event!.id}/";
              } else {
                // endpoint create
                url = "http://localhost:8000/event/create-flutter/";
              }

              final response = await request.postJson(
                url,
                jsonEncode({
                  "name": _name,
                  "description": _description,
                  "location": _location,
                  "start_date": _startDateController.text,
                  "end_date": _endDateController.text,
                  "max_participants": _maxParticipants,
                  "image_url": _imageUrl,
                }),
              );

              if (context.mounted) {
                if (response['status'] == 'success') {
                  Navigator.pop(context, true); // send sinyal 'true' agar halaman sebelumnya refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? "Success!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${response['message']}")),
                  );
                }
              }
            }
          },
          child: Text(buttonText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}