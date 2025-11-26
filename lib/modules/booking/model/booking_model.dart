import 'dart:convert';
import 'package:flutter/foundation.dart';
// dummy data
import 'dummy_lapangan_model.dart';
import 'dummy_jadwal_lapangan_model.dart';



// Model Utama untuk data Booking
class Booking {
  final String id;
  final Lapangan lapangan;
  // User fields diintegrasikan langsung
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
    // Parsing data Lapangan (dari show_json)
    final Map<String, dynamic> lapanganJson = json['lapangan'] as Map<String, dynamic>;
    final Lapangan lapangan = Lapangan.fromJson({
      'id': lapanganJson['id'],
      'name': lapanganJson['name'],
      'price': lapanganJson['price'], 
      'location': lapanganJson['location'] ?? 'N/A', 
      'image': lapanganJson['image'] ?? null, 
    });

    // Parsing data User diintegrasikan langsung dari JSON
    final Map<String, dynamic> userJson = json['user'] as Map<String, dynamic>;
    final String userId = userJson['id'] is String ? userJson['id'] : userJson['id'].toString();
    final String userFullname = userJson['fullname'] as String;

    // Parsing data Jadwal
    final List<Jadwal> jadwalList = (json['jadwal'] as List<dynamic>)
        .map((j) => Jadwal.fromJson({
              'id': j['id'] ?? (j['tanggal'] + j['start_main']), // Fallback ID jika tidak ada
              'tanggal': j['tanggal'],
              'start_main': j['start_main'],
              'end_main': j['end_main'],
              'is_available': j['is_available'] ?? false, 
            }))
        .toList();

    return Booking(
      id: json['id'] as String,
      lapangan: lapangan,
      // Diperbarui
      userId: userId,
      userFullname: userFullname,
      
      statusBook: json['status_book'] as String,
      // Total price dari Django adalah float
      totalPrice: (json['total_price'] as num).toDouble(), 
      // created_at bisa berupa string ISO 8601
      createdAt: DateTime.parse(json['created_at'].toString()), 
      jadwal: jadwalList,
    );
  }
}