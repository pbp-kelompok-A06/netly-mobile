import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:netly_mobile/modules/booking/model/booking_model.dart';
import 'package:netly_mobile/modules/booking/model/dummy_jadwal_lapangan_model.dart';
import 'package:netly_mobile/modules/booking/model/dummy_lapangan_model.dart';

class BookingService {
  static const String _baseUrl = "http://127.0.0.1:8000";

  final CookieRequest request;

  BookingService({required this.request});

  Future<Map<String, dynamic>> fetchAvailableSchedules(
    String lapanganId,
  ) async {
    final url = '$_baseUrl/booking/get_booking_data_flutter/$lapanganId/';

    final response = await request.get(url);

    if (response is List) {
      final jsonResponse = response.first;

      final Lapangan lapangan = Lapangan.fromJson(
        jsonResponse['lapangan'] as Map<String, dynamic>,
      );

      final List<Jadwal> jadwalList = (jsonResponse['jadwal_list'] as List)
          .map((j) => Jadwal.fromJson(j as Map<String, dynamic>))
          .toList();

      return {'lapangan': lapangan, 'jadwalList': jadwalList};
    } else if (response is Map) {
      final Map<String, dynamic> jsonResponse =
          response as Map<String, dynamic>;

      if (jsonResponse.containsKey('lapangan')) {
        final Lapangan lapangan = Lapangan.fromJson(
          jsonResponse['lapangan'] as Map<String, dynamic>,
        );
        final List<Jadwal> jadwalList = (jsonResponse['jadwal_list'] as List)
            .map((j) => Jadwal.fromJson(j as Map<String, dynamic>))
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

  Future<List<Booking>> fetchBookings() async {
    final url = '$_baseUrl/booking/show_json/';

    final response = await request.get(url);

    if (response is List) {
      return response
          .map((b) => Booking.fromJson(b as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Gagal memuat daftar booking. Pastikan Anda sudah login.',
      );
    }
  }

  Future<Booking> fetchBookingDetail(String bookingId) async {
    final url = '$_baseUrl/booking/show_json_id/$bookingId/';

    final response = await request.get(url);

    if (response is Map) {
      return Booking.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception(
        'Gagal memuat detail booking. Pastikan ID valid dan Anda sudah login.',
      );
    }
  }

  Future<Map<String, dynamic>> createBooking(
    String lapanganId,
    List<String> jadwalIds,
  ) async {
    final url = '$_baseUrl/booking/create_booking/';

    final Map<String, dynamic> body = {
      'lapangan_id': lapanganId,

      'jadwal_id': jadwalIds,
    };

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

  Future<bool> completePayment(String bookingId) async {
    final url = '$_baseUrl/booking/booking_detail/$bookingId/complete/';

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
