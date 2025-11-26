import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Import CookieRequest
import 'package:flutter/foundation.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';

import 'package:netly-mobile/modules/booking/model/jadwal_model.dart'; 
import 'package:netly-mobile/modules/lapangan/model/lapangan_model.dart';

class BookingService {
  // Ganti dengan Base URL Django Anda
  static const String _baseUrl = "http://127.0.0.1:8000"; 
  
  // Menggunakan CookieRequest untuk handling session dan CSRF
  final CookieRequest request;

  // Constructor menerima instance CookieRequest dari Provider
  BookingService({required this.request}); 

  // --- Operasi GET ---

  // Mengambil jadwal yang tersedia dan detail lapangan 
  // Endpoint Django: /booking/get_booking_data_flutter/<lapangan_id>/
  Future<Map<String, dynamic>> fetchAvailableSchedules(String lapanganId) async {
    final url = '$_baseUrl/booking/get_booking_data_flutter/$lapanganId/';
    // Gunakan request.get() dari CookieRequest
    final response = await request.get(url); 

    if (response is List) {
      // Endpoint ini mengembalikan JSON object, bukan list.
      // Diasumsikan response sukses adalah Map
      final jsonResponse = response.first; 
      
      // Ambil data Lapangan
      final Lapangan lapangan = Lapangan.fromJson(jsonResponse['lapangan'] as Map<String, dynamic>);
      
      // Ambil dan konversi list Jadwal
      final List<Jadwal> jadwalList = (jsonResponse['jadwal_list'] as List)
          .map((j) => Jadwal.fromJson(j as Map<String, dynamic>))
          .toList();

      return {
        'lapangan': lapangan,
        'jadwalList': jadwalList,
      };
    } else if (response is Map) {
      final Map<String, dynamic> jsonResponse = response as Map<String, dynamic>;
      
      if (jsonResponse.containsKey('lapangan')) {
        // Response sukses (Map<String, dynamic>)
        final Lapangan lapangan = Lapangan.fromJson(jsonResponse['lapangan'] as Map<String, dynamic>);
        final List<Jadwal> jadwalList = (jsonResponse['jadwal_list'] as List)
            .map((j) => Jadwal.fromJson(j as Map<String, dynamic>))
            .toList();

        return {
          'lapangan': lapangan,
          'jadwalList': jadwalList,
        };
      }
      
      // Response error dari Django (misalnya 404)
      throw Exception('Gagal memuat jadwal: ${jsonResponse['message'] ?? 'Unknown Error'}');
    }
     else {
       throw Exception('Gagal memuat jadwal: Invalid response format.');
    }
  }

  // Mengambil daftar booking user atau admin
  // Endpoint Django: /booking/show_json/
  Future<List<Booking>> fetchBookings() async {
    final url = '$_baseUrl/booking/show_json/';
    // Gunakan request.get() dari CookieRequest
    final response = await request.get(url);

    if (response is List) {
      // Response sukses adalah List<Map<String, dynamic>>
      return response.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
    } else {
      // Jika response bukan List, mungkin ada error dari Django
      throw Exception('Gagal memuat daftar booking. Pastikan Anda sudah login.');
    }
  }

  // Mengambil detail booking berdasarkan ID
  // Endpoint Django: /booking/show_json_id/<booking_id>/
  Future<Booking> fetchBookingDetail(String bookingId) async {
    final url = '$_baseUrl/booking/show_json_id/$bookingId/';
    // Gunakan request.get() dari CookieRequest
    final response = await request.get(url);

    if (response is Map) {
      // Response sukses adalah Map<String, dynamic>
      return Booking.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Gagal memuat detail booking. Pastikan ID valid dan Anda sudah login.');
    }
  }

  // --- Operasi POST/UPDATE ---
  
  // Membuat booking baru
  // Endpoint Django: /booking/create_booking/
  Future<Map<String, dynamic>> createBooking(String lapanganId, List<String> jadwalIds) async {
    final url = '$_baseUrl/booking/create_booking/';
    
    // Siapkan body dalam format Map<String, dynamic> untuk CookieRequest.post
    // CookieRequest akan mengubahnya menjadi form-urlencoded.
    final Map<String, dynamic> body = {
      'lapangan_id': lapanganId,
      // Karena Django menggunakan request.POST.getlist('jadwal_id'),
      // kita harus mengirim data ini dalam format list/array di body.
      // CookieRequest akan menanganinya saat serialisasi ke form-urlencoded.
      'jadwal_id': jadwalIds, 
    };
    
    // Menggunakan request.post() dari CookieRequest
    final response = await request.post(url, body);

    if (response is Map) {
      final Map<String, dynamic> data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return {
          'success': true, 
          'bookingId': data['booking_id'],
          'paymentUrl': data['payment_url'],
        };
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat booking.');
      }
    } else {
      throw Exception('Format respon tidak valid.');
    }
  }

  // Mengonfirmasi pembayaran
  // Endpoint Django: /booking/booking_detail/<booking_id>/complete/
  Future<bool> completePayment(String bookingId) async {
    final url = '$_baseUrl/booking/booking_detail/$bookingId/complete/';
    
    // POST request tanpa body. CookieRequest akan mengirim CSRF token.
    final response = await request.post(url, {});

    if (response is Map) {
      final Map<String, dynamic> data = response as Map<String, dynamic>;
      if (data['status'] == 'Completed') {
        return true;
      } else if (data.containsKey('message')) {
         throw Exception(data['message']);
      } else {
        throw Exception('Pembayaran gagal. Status bukan Completed.');
      }
    } else {
      throw Exception('Gagal mengonfirmasi pembayaran. Format respon tidak valid.');
    }
  }
}