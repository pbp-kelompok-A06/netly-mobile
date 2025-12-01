import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/lapangan/model/lapangan_model.dart'
    as Lapangan;
import 'package:netly_mobile/modules/lapangan/model/jadwal_lapangan_model.dart'
    as Jadwal;
import 'package:netly_mobile/utils/path_web.dart';

class BookingService {
  final CookieRequest request;

  BookingService({required this.request});

  Future<Map<String, dynamic>> fetchAvailableSchedules(
    String lapanganId,
  ) async {
    final url = '$pathWeb/booking/get_booking_data_flutter/$lapanganId/';

    final response = await request.get(url);

    if (response is List) {
      final jsonResponse = response.first;

      final Lapangan.Datum lapangan = Lapangan.Datum.fromJson(
        jsonResponse['lapangan'] as Map<String, dynamic>,
      );

      final List<Jadwal.Datum> jadwalList =
          (jsonResponse['jadwal_list'] as List)
              .map((j) => Jadwal.Datum.fromJson(j as Map<String, dynamic>))
              .toList();

      return {'lapangan': lapangan, 'jadwalList': jadwalList};
    } else if (response is Map) {
      final Map<String, dynamic> jsonResponse =
          response as Map<String, dynamic>;

      if (jsonResponse.containsKey('lapangan')) {
        final Lapangan.Datum lapangan = Lapangan.Datum.fromJson(
          jsonResponse['lapangan'] as Map<String, dynamic>,
        );
        final List<Jadwal.Datum> jadwalList =
            (jsonResponse['jadwal_list'] as List)
                .map((j) => Jadwal.Datum.fromJson(j as Map<String, dynamic>))
                .toList();

        return {'lapangan': lapangan, 'jadwalList': jadwalList};
      }

      throw Exception(
        'Gagal memuat jadwal: ${jsonResponse['message'] ?? 'Unknown Error'}',
      );
    } else {
      throw Exception('Gagal memuat jadwal: Invalid response format.');
    }
  }

  Future<List<Booking>> fetchAllBookings(CookieRequest request) async {
    // Ganti dengan endpoint API Django Anda untuk mendapatkan list booking mentah

    try {
      final response = await request.get('$pathWeb/booking/show_json/');

        final List rawData = response as List;


        // Proses setiap item secara paralel (concurrent)
        final List<Future<Booking>> futures = rawData.map((jsonItem) {
          // PENTING: Meneruskan objek 'request' ke fromRawJson
          return Booking.fromRawJson(jsonItem as Map<String, dynamic>, request);
        }).toList();

        // Tunggu semua proses fetching detail selesai
        final List<Booking> completedBookings = await Future.wait(futures);

        return completedBookings;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error di fetchAllBookings: $e');
      }
      rethrow;
    }
  }

  Future<Booking> fetchBookingDetail(
    String bookingId,
    CookieRequest request,
  ) async {
    final url = '$pathWeb/booking/show_json_id/$bookingId/';

    final response = await request.get(url);

    
      final Map<String, dynamic> jsonData =
          response as Map<String, dynamic>;

      // PENTING: Meneruskan objek 'request' ke fromRawJson
      final Booking booking = await Booking.fromRawJson(jsonData, request);

      return booking;

  }

  Future<Map<String, dynamic>> createBooking(
    String lapanganId,
    List<String> jadwalIds,
  ) async {
    print(  "Creating booking for Lapangan ID: $lapanganId with Jadwal IDs: $jadwalIds");
    final url = '$pathWeb/booking/create_booking_flutter/';
    
    final Map<String, dynamic> body = {
      'lapangan_id': lapanganId,

      'jadwal_id': jadwalIds,
    };

    final response = await request.postJson(url, jsonEncode(body));
    print("response from createBooking: $response");
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

  Future<bool> completePayment(String bookingId) async {
    final url = '$pathWeb/booking/booking_detail/$bookingId/complete/';

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
      throw Exception(
        'Gagal mengonfirmasi pembayaran. Format respon tidak valid.',
      );
    }
  }
}
