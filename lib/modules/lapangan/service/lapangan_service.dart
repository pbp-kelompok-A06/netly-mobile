import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class LapanganService {
  final CookieRequest request;

  LapanganService(this.request);

  // Fetch all lapangan
  Future<LapanganModel?> fetchAllLapangan({String search = ''}) async {
    try {
      String url = '$pathWeb/lapangan/api/lapangan/';

      if (search.isNotEmpty) {
        url += '?search=$search';
      }

      final response = await request.get(url);

      if (response != null) {
        return LapanganModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching lapangan: $e');
      return null;
    }
  }

  // Fetch lapangan detail
  Future<Map<String, dynamic>?> fetchLapanganDetail(String id) async {
    try {
      final response = await request.get(
        '$pathWeb/lapangan/api/lapangan/$id/',
      );

      if (response != null && response['status'] == 'success') {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching lapangan detail: $e');
      return null;
    }
  }

  // Create new lapangan (admin only)
  Future<Map<String, dynamic>> createLapangan({
    required String name,
    required String location,
    required String description,
    required String price,
    String? image,
  }) async {
    
      final url = '$pathWeb/lapangan/create-flutter/';
      final data = {
        'name': name,
        'location': location,
        'description': description,
        'price': price,
        'image': image ?? '',
      };

      final response = await request.post(url, data);

      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Lapangan berhasil ditambahkan!',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal menambahkan lapangan',
        };
      
    }
  }

  // Edit lapangan (admin only)
  Future<Map<String, dynamic>> editLapangan({
    required String id,
    required String name,
    required String location,
    required String description,
    required String price,
    String? image,
  }) async {
    try {
      // Fixed URL - remove duplicate /lapangan/
      final response = await request
          .post('$pathWeb/lapangan/ajax/edit/$id/', {
            'name': name,
            'location': location,
            'description': description,
            'price': price,
            'image': image ?? '',
          });

      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Lapangan berhasil diperbarui!',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal memperbarui lapangan',
        };
      }
    } catch (e) {
      print('Error editing lapangan: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete lapangan (admin only)
  Future<Map<String, dynamic>> deleteLapangan(String id) async {
    try {
      // Fixed URL - remove duplicate /lapangan/
      final response = await request.post(
        '$pathWeb/lapangan/ajax/delete/$id/',
        {},
      );

      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? 'Lapangan berhasil dihapus!',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal menghapus lapangan',
        };
      }
    } catch (e) {
      print('Error deleting lapangan: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
