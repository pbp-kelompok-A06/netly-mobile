import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/modules/lapangan/service/jadwal_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class JadwalFormPage extends StatefulWidget {
  final Datum lapangan;
  final JadwalData? jadwal; // Null untuk create, filled untuk edit

  const JadwalFormPage({
    super.key,
    required this.lapangan,
    this.jadwal,
  });

  @override
  State<JadwalFormPage> createState() => _JadwalFormPageState();
}

class _JadwalFormPageState extends State<JadwalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isLoading = false;

  bool get _isEditMode => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditMode) {
      // Edit mode - populate with existing data
      _selectedDate = widget.jadwal!.tanggal;
      _startTime = _parseTimeString(widget.jadwal!.startMain);
      _endTime = _parseTimeString(widget.jadwal!.endMain);
    } else {
      // Create mode - default values
      _selectedDate = DateTime.now();
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF243153),
              onPrimary: Color(0xFFD7FC64),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF243153),
              onPrimary: Color(0xFFD7FC64),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF243153),
              onPrimary: Color(0xFFD7FC64),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String? _validateForm() {
    // Check if date is not in the past (for create mode)
    if (!_isEditMode) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      
      if (selected.isBefore(today)) {
        return 'The date cannot be in the past';
      }
    }

    // Check if start time is before end time
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (startMinutes >= endMinutes) {
      return 'Start time must be earlier than finish time';
    }

    // Check minimum duration (e.g., 1 hour)
    if (endMinutes - startMinutes < 60) {
      return 'Minimum duration is 1 hour';
    }

    return null;
  }

  Future<void> _submitForm() async {
    final validationError = _validateForm();
    
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final jadwalService = JadwalService(request);

    try {
      final Map<String, dynamic> result;

      if (_isEditMode) {
        // Update existing jadwal
        result = await jadwalService.updateJadwal(
          jadwalId: widget.jadwal!.id,
          tanggal: _selectedDate,
          startMain: _formatTimeOfDay(_startTime),
          endMain: _formatTimeOfDay(_endTime),
        );
      } else {
        // Create new jadwal
        result = await jadwalService.createJadwal(
          lapanganId: widget.lapangan.id,
          tanggal: _selectedDate,
          startMain: _formatTimeOfDay(_startTime),
          endMain: _formatTimeOfDay(_endTime),
        );
      }

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There is an error: $e'),
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
        title: Text(
          _isEditMode ? 'Reschedule' : 'Add Schedule',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isEditMode 
                                  ? 'Edit schedule for ${widget.lapangan.name}'
                                  : 'Create schedule for ${widget.lapangan.name}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date Picker
              const Text(
                'Date *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF243153)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Start Time Picker
              const Text(
                'Start Time *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectStartTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF243153)),
                      const SizedBox(width: 12),
                      Text(
                        _formatTimeOfDay(_startTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // End Time Picker
              const Text(
                'End Time *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectEndTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF243153)),
                      const SizedBox(width: 12),
                      Text(
                        _formatTimeOfDay(_endTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Duration Info
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Duration: ${(_endTime.hour * 60 + _endTime.minute) - (_startTime.hour * 60 + _startTime.minute)} minute',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
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
                    : Text(
                        _isEditMode ? 'Save Changes' : 'Add Schedule',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Helper text
              const Text(
                '* Required fields\n\Note:\n- The date cannot be in the past\n- Start time must be earlier than finish time\n- Minimum duration 1 hour',
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