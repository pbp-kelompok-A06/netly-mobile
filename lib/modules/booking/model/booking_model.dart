import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'dummy_lapangan_model.dart';
import 'dummy_jadwal_lapangan_model.dart';

// Model Utama untuk data Booking
class Booking {
  final String id;
  final Lapangan lapangan;

  // User fields
  final String userId;
  final String userFullname;

  final String statusBook;
  final double totalPrice;
  final DateTime createdAt;

  final List<Jadwal> jadwal;

  Booking({
    required this.id,
    required this.lapangan,
    required this.userId,
    required this.userFullname,
    required this.statusBook,
    required this.totalPrice,
    required this.createdAt,
    required this.jadwal,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parsing Lapangan
    final lapanganJson = json['lapangan'] as Map<String, dynamic>;
    // di sini menggunakan field yang sesuai dari JSON untuk menggunakan objek lapangan yang ada di data base
    final lapangan = Lapangan.fromJson({
      'id': lapanganJson['id'],
      'name': lapanganJson['name'],
      'price': lapanganJson['price'],
    });

    // Parsing User
    final userJson = json['user'] as Map<String, dynamic>;
    final userId = userJson['id'].toString();
    final userFullname = userJson['fullname'] ?? '';

    // Parsing Jadwal
    final jadwalList = (json['jadwal'] as List<dynamic>).map((j) {
      return Jadwal.fromJson({
        'id': "${j['tanggal']}_${j['start_main']}",  // fallback id
        'tanggal': j['tanggal'],
        'start_main': j['start_main'],
        'end_main': j['end_main'],
        'is_available': j['is_available'] ?? false,
      });
    }).toList();

    return Booking(
      id: json['id'].toString(),
      lapangan: lapangan,
      userId: userId,
      userFullname: userFullname,
      statusBook: json['status_book'],
      
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      jadwal: jadwalList,
    );
  }
}
