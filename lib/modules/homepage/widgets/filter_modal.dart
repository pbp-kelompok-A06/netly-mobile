import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final String? initialLocation;
  final String? initialMinPrice;
  final String? initialMaxPrice;
  final Function(String?, String?, String?) onApply;

  const FilterModal({
    super.key,
    this.initialLocation,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? selectedLocation;
  late TextEditingController minController;
  late TextEditingController maxController;

  final List<String> cities = [
    "Jakarta Barat", "Jakarta Selatan", "Jakarta Utara", "Jakarta Pusat", "Jakarta Timur",
    "Depok", "Bogor", "Tangerang", "Tangerang Selatan", "Bekasi",
    "Bandung", "Surabaya", "Malang", "Medan", "Bali", "Yogyakarta"
  ];

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
    minController = TextEditingController(text: widget.initialMinPrice);
    maxController = TextEditingController(text: widget.initialMaxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))),
            )
          ),
          const SizedBox(height: 20),
          const Text("Filter Courts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: (selectedLocation != null && cities.contains(selectedLocation)) 
                ? selectedLocation 
                : null,
            dropdownColor: Colors.white,
            decoration: const InputDecoration(
              labelText: "Location",
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            hint: const Text("Select Location"),
            items: cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Min Price",
                    prefixText: "Rp ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Max Price",
                    prefixText: "Rp ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF243153),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onApply(selectedLocation, minController.text, maxController.text);
                Navigator.pop(context);
              },
              child: const Text("Apply Filter", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                widget.onApply(null, null, null); 
                Navigator.pop(context);
              },
              child: const Text("Reset Filter", style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}