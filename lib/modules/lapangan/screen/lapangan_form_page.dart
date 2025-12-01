import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netly_mobile/modules/lapangan/service/lapangan_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LapanganFormPage extends StatefulWidget {
  const LapanganFormPage({super.key});

  @override
  State<LapanganFormPage> createState() => _LapanganFormPageState();
}

class _LapanganFormPageState extends State<LapanganFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lapangan harus diisi';
    }
    if (value.length < 3) {
      return 'Nama lapangan minimal 3 karakter';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lokasi harus diisi';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deskripsi harus diisi';
    }
    if (value.length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga harus diisi';
    }
    final price = int.tryParse(value);
    if (price == null) {
      return 'Harga harus berupa angka';
    }
    if (price < 0) {
      return 'Harga tidak boleh negatif';
    }
    if (price < 10000) {
      return 'Harga minimal Rp 10.000';
    }
    return null;
  }

  String? _validateImage(String? value) {
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return 'URL gambar tidak valid';
      }
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final lapanganService = LapanganService(request);

    try {
      final result = await lapanganService.createLapangan(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        image: _imageController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        // Log working URL if available
        if (result['working_url'] != null) {
          print('✅ Working URL: ${result['working_url']}');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Check if error message is long (multiple URLs tried)
        final errorMessage = result['message'] as String;
        
        if (errorMessage.length > 150) {
          // Show detailed error in dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Endpoint Error'),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(errorMessage),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Show short error in SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Lapangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243153),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lapangan *',
                  hintText: 'Contoh: Lapangan Badminton A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.sports_tennis),
                ),
                validator: _validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasi *',
                  hintText: 'Contoh: Jakarta Selatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: _validateLocation,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi *',
                  hintText: 'Deskripsi fasilitas dan keunggulan lapangan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: _validateDescription,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Harga per Jam (Rp) *',
                  hintText: 'Contoh: 50000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  helperText: 'Masukkan harga dalam Rupiah',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: _validatePrice,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Image URL Field
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: 'URL Gambar (Opsional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.image),
                  helperText: 'Masukkan URL gambar dari internet',
                ),
                keyboardType: TextInputType.url,
                validator: _validateImage,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF243153),
                  foregroundColor: const Color(0xFFD7FC64),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD7FC64),
                          ),
                        ),
                      )
                    : const Text(
                        'Tambah Lapangan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Helper text
              const Text(
                '* Wajib diisi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}