import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart'
    as Lapangan; // Import package untuk otentikasi
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart';
     

// Menggunakan Import Aliasing untuk mengatasi konflik nama kelas 'Datum'

// Model Utama untuk data Booking
class Booking {
  final String id;
  // Menggunakan Lapangan.Datum untuk detail lapangan
  final Lapangan.Datum lapangan;

  // User fields
  final String userId;
  final String userFullname;

  final String statusBook;
  final int totalPrice;
  final DateTime createdAt;

  // Menggunakan List JadwalData untuk detail jadwal
  final List<JadwalData> jadwal;

  // Constructor privat, dipanggil hanya setelah fetching detail selesai
  Booking._({
    required this.id,
    required this.lapangan,
    required this.userId,
    required this.userFullname,
    required this.statusBook,
    required this.totalPrice,
    required this.createdAt,
    required this.jadwal,
  });

  // --- Static Asynchronous Constructor ---

  // Metode untuk membuat objek Booking LENGKAP dari raw JSON yang hanya berisi ID.
  static Future<Booking> fromRawJson(
    
    Map<String, dynamic> json,
    CookieRequest request,
  ) async {
    // 1. Ekstraksi ID Lapangan dan ID Jadwal dari JSON booking awal


    final lapanganJson = json['lapangan'] as Map<String, dynamic>;
    final String lapanganId = lapanganJson['id'].toString();

    final userJson = json['user'] as Map<String, dynamic>;
    final userId = userJson['id'].toString();
    final userFullname = userJson['fullname'] ?? '';

    // Ambil List of ID Jadwal
    final List<String> jadwalIdsList = (json['jadwal'] as List<dynamic>)
        .map((j) => j['id']?.toString() ?? "${j['tanggal']}_${j['start_main']}")
        .toList();

    // 2. Fetch Detail Lapangan dan Jadwal secara paralel (Concurrent fetching)

    // Meneruskan request cookie untuk otentikasi
    final futureLapangan = _fetchLapanganDetail(lapanganId, request);
    final futureJadwal = Future.wait(
      jadwalIdsList.map((id) => _fetchJadwalDetail(id, request)).toList(),
    );

    try {
          
    
      // Tunggu hasil dari fetching detail
      final Lapangan.Datum detailLapangan = await futureLapangan;
      final List<JadwalData> detailsJadwal = await futureJadwal;

      // 3. Kembalikan objek Booking lengkap
      return Booking._(
        id: json['id'].toString(),
        lapangan: detailLapangan,
        userId: userId,
        userFullname: userFullname,
        statusBook: json['status_book'],
        totalPrice: double.parse(json['total_price'].toString()).toInt(),
        createdAt: DateTime.parse(json['created_at']),
        jadwal: detailsJadwal,
      );
    } catch (e) {
      if (kDebugMode) {
        print("masuk baru");
        print('Error baru lagi fetching booking details: $StackTrace');
      }
      rethrow;
    }
  }

  // --- Helper Functions untuk Fetching Detail ---

  // Fetches detail Lapangan menggunakan CookieRequest
  static Future<Lapangan.Datum> _fetchLapanganDetail(
    String id,
    CookieRequest request,
  ) async {
    // Menggunakan pathWeb['netly']
    final url = "$pathWeb/booking/get_lapangan_detail_json/$id/";
    final response = await request.get(url);

    var data = response['data'];

    if (response['status'] == 'success') {
      if (data != null && data['price'] != null) {
      
      data['price'] = (data['price'] as num).toInt();
    }
      return Lapangan.Datum.fromJson(data);
    } else {
      throw Exception(
        'Gagal memuat detail Lapangan ID: $id. Pesan: ${response['message']}',
      );
    }
  }

  // Fetches detail Jadwal menggunakan CookieRequest
  static Future<JadwalData> _fetchJadwalDetail(
    String id,
    CookieRequest request,
  ) async {
    
    final url = "$pathWeb/booking/get_jadwal_detail_json/$id/";
    final response = await request.get(url);
    
    

    if (response['status'] == 'success') {
      return JadwalData.fromJson(response['data']);
    } else {
      throw Exception(
        'Gagal memuat detail Jadwal ID: $id. Pesan: ${response['message']}',
      );
    }
  }
}
