import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart'
    as Lapangan; // Import package untuk otentikasi
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart'
    as Jadwal; // Import variabel pathWeb Anda

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
  final double totalPrice;
  final DateTime createdAt;

  // Menggunakan List Jadwal.Datum untuk detail jadwal
  final List<Jadwal.Datum> jadwal;

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
          print("RAW BOOKING JSON:");
    print(json);
      // Tunggu hasil dari fetching detail
      final Lapangan.Datum detailLapangan = await futureLapangan;
      final List<Jadwal.Datum> detailsJadwal = await futureJadwal;

      // 3. Kembalikan objek Booking lengkap
      return Booking._(
        id: json['id'].toString(),
        lapangan: detailLapangan,
        userId: userId,
        userFullname: userFullname,
        statusBook: json['status_book'],
        totalPrice: double.parse(json['total_price'].toString()),
        createdAt: DateTime.parse(json['created_at']),
        jadwal: detailsJadwal,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching booking details: $e');
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
    final url = "$pathWeb/lapangan/api/lapangan/$id/";
    final response = await request.get(url);

    print("LAPANGAN DETAIL:");
    print(response['data']);

    if (response['status'] == 'success') {
      return Lapangan.Datum.fromJson(response['data']);
    } else {
      throw Exception(
        'Gagal memuat detail Lapangan ID: $id. Pesan: ${response['message']}',
      );
    }
  }

  // Fetches detail Jadwal menggunakan CookieRequest
  static Future<Jadwal.Datum> _fetchJadwalDetail(
    String id,
    CookieRequest request,
  ) async {
    print(  "Fetching Jadwal ID: $id");
    final url = "$pathWeb/booking/get_jadwal_detail_json/$id/";
    final response = await request.get(url);
    print("JADWAL DETAIL:");
    print(response);

    if (response['status'] == 'success') {
      return Jadwal.Datum.fromJson(response['data']);
    } else {
      throw Exception(
        'Gagal memuat detail Jadwal ID: $id. Pesan: ${response['message']}',
      );
    }
  }
}
