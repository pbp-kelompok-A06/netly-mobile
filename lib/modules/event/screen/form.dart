import 'package:flutter/material.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

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

  // controller untuk field tanggal
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // set nilai awal tanggal ke hari ini
    _startDateController.text = DateTime.now().toString().substring(0, 10); 
    _endDateController.text = DateTime.now().toString().substring(0, 10);
  }

  @override
  void dispose() {
    // bersihkan controller ketika halaman udah diclose
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // untuk menampilkan kalender
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // tanggal yang selected saat kalender buka
      firstDate: DateTime(2000),   // batas awal tanggal
      lastDate: DateTime(2101),    // batas akhir tanggal
    );

    if (picked != null) {
      setState(() {
        // format tanggal jadi YYYY-MM-DD (ambil 10 karakter pertama)
        controller.text = picked.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'Create New Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF243153),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      scrollable: true,
      
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // nama
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Event Name",
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _name = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Name cannot be empty";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
  
                // lokasi
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Location",
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _location = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Location cannot be empty";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // start Date
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController, //connect ke controller
                        readOnly: true, // readonly, ga bisa ketik atau muncul keyboard
                        decoration: InputDecoration(
                          labelText: "Start Date",
                          labelStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        // kalo diklik, panggil fungsi _selectDate
                        onTap: () => _selectDate(context, _startDateController),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // end Date
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true, 
                        decoration: InputDecoration(
                          labelText: "End Date",
                          labelStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        // Saat diklik, panggil fungsi _selectDate
                        onTap: () => _selectDate(context, _endDateController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
  
                // max participants
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Max Participants",
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
  
                // Image URL
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Image URL",
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _imageUrl = value),
                ),
                const SizedBox(height: 12),
  
                // Description
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _description = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Description cannot be empty";
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
      
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF243153),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: save ke database
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Event created successfully!"))
              );
            }
          },
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}