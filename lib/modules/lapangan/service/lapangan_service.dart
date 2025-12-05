import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class LapanganService {
  final CookieRequest request;

  LapanganService(this.request);

  // Get base URL
  String get baseUrl => pathWeb['localhost']!;

  // Fetch all lapangan
  Future<LapanganModel?> fetchAllLapangan({
    String search = '',
    bool? myLapangan,
  }) async {
    try {
      String url;

      // Pisahkan URL tujuan berdasarkan apakah user ingin melihat "My Lapangan" atau semua.
      if (myLapangan == true) {
        url = '$baseUrl/lapangan/api/my-lapangan/'; 
      } else {
        // URL default untuk mengambil semua lapangan (publik)
        url = '$baseUrl/lapangan/api/lapangan/';
      }

      // Handle Query Params (khususnya Search)
      // Kode Django Anda menerima 'search' via request.GET.get('search')
      List<String> queryParams = [];
      if (search.isNotEmpty) {
        queryParams.add('search=$search');
      }

      // Gabungkan URL dengan query params jika ada
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      // Lakukan request GET
      // CookieRequest akan otomatis membawa session ID user yang login,
      // sehingga 'request.user' di Django akan terdeteksi.
      final response = await request.get(url);

      if (response != null) {
        return LapanganModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch single lapangan detail
  Future<Datum?> fetchLapanganDetail(String id) async {
    try {
      final response = await request.get(
        '$baseUrl/lapangan/api/lapangan/$id/',
      );

      if (response != null && response['status'] == 'success') {
        return Datum.fromJson(response['data']);
      }
      return null;
    } catch (e) {
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
    final url = '$baseUrl/lapangan/create-flutter/';
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
        'message': response['message'] ?? 'Court successfully added!',
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to add Court',
      };
    }
  }

  // Update lapangan (admin only)
  Future<Map<String, dynamic>> updateLapangan({
    required String id,
    required String name,
    required String location,
    required String description,
    required String price,
    String? image,
  }) async {
    // GUNAKAN FORMAT YANG SAMA DENGAN CREATE
    final url = '$baseUrl/lapangan/edit-flutter/$id/';
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
        'message': response['message'] ?? 'Court successfully updated!',
        'data': response.containsKey('data') ? response['data'] : null,
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update field',
      };
    }
  }

  // Delete lapangan (admin only)
  Future<Map<String, dynamic>> deleteLapangan(String id) async {
    final url = '$baseUrl/lapangan/delete-flutter/$id/';

    final response = await request.post(url, {});

    if (response['status'] == 'success') {
      return {
        'success': true,
        'message': response['message'] ?? 'Field successfully deleted!',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to delete field',
      };
    }
  }

  // Check if user is admin
  bool isUserAdmin() {
    try {
      final userData = request.jsonData['userData'];
      return userData != null && userData['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Get current user info
  Map<String, dynamic>? getCurrentUser() {
    try {
      return request.jsonData['userData'];
    } catch (e) {
      return null;
    }
  }
}