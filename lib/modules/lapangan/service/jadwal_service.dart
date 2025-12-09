import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class JadwalService {
  final CookieRequest request;

  JadwalService(this.request);

  String get baseUrl => pathWeb;

  // Fetch all jadwal for a specific lapangan
  Future<JadwalLapanganModel?> fetchJadwalByLapangan({
    required String lapanganId,
    DateTime? filterDate,
  }) async {
    try {
      String url = '$baseUrl/lapangan/api/jadwal/$lapanganId/';

      if (filterDate != null) {
        final dateStr = '${filterDate.year}-${filterDate.month.toString().padLeft(2, '0')}-${filterDate.day.toString().padLeft(2, '0')}';
        url += '?date=$dateStr';
      }


      final response = await request.get(url);

      if (response != null) {
        return JadwalLapanganModel.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch single jadwal detail
  Future<JadwalData?> fetchJadwalDetail(String jadwalId) async {
    try {
      final response = await request.get(
        '$baseUrl/lapangan/api/jadwal/detail/$jadwalId/',
      );

      if (response != null && response['status'] == 'success') {
        return JadwalData.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create new jadwal (admin only)
  Future<Map<String, dynamic>> createJadwal({
    required String lapanganId,
    required DateTime tanggal,
    required String startMain,
    required String endMain,
  }) async {
    try {
      final url = '$baseUrl/lapangan/jadwal/create-flutter/';
      final dateStr = '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
      
      final data = {
        'lapangan_id': lapanganId,
        'tanggal': dateStr,
        'start_main': startMain,
        'end_main': endMain,
      };


      final response = await request.post(url, data);


      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Schedule successfully added!',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to add schedule',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'There is an error: ${e.toString()}',
      };
    }
  }

  // Update jadwal (admin only)
  Future<Map<String, dynamic>> updateJadwal({
    required String jadwalId,
    required DateTime tanggal,
    required String startMain,
    required String endMain,
    bool? isAvailable,
  }) async {
    try {
      final url = '$baseUrl/lapangan/jadwal/edit-flutter/$jadwalId/';
      final dateStr = '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
      
      final data = {
        'tanggal': dateStr,
        'start_main': startMain,
        'end_main': endMain,
        if (isAvailable != null) 'is_available': isAvailable.toString(),
      };

      final response = await request.post(url, data);


      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Schedule updated successfully!',
          'data': response.containsKey('data') ? response['data'] : null,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update schedule',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'There is an error: ${e.toString()}',
      };
    }
  }

  // Delete jadwal (admin only)
  Future<Map<String, dynamic>> deleteJadwal(String jadwalId) async {
    try {
      final url = '$baseUrl/lapangan/jadwal/delete-flutter/$jadwalId/';


      final response = await request.post(url, {});


      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Schedule successfully deleted!',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete schedule',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'There is an error: ${e.toString()}',
      };
    }
  }

  // Toggle availability
  Future<Map<String, dynamic>> toggleAvailability({
    required String jadwalId,
    required bool isAvailable,
  }) async {
    try {
      final url = '$baseUrl/lapangan/jadwal/toggle-availability/$jadwalId/';
      
      final data = {
        'is_available': isAvailable.toString(),
      };

      final response = await request.post(url, data);

      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Availability status changed successfully!',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to change status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'There is an error: ${e.toString()}',
      };
    }
  }
}