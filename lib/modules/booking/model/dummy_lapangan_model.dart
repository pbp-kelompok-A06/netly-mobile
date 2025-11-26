// file: lapangan.dart
import 'dart:convert';

// Fungsi untuk mengkonversi JSON string ke objek Lapangan
Lapangan lapanganFromJson(String str) => Lapangan.fromJson(json.decode(str));

// Fungsi untuk mengkonversi objek Lapangan ke JSON string
String lapanganToJson(Lapangan data) => json.encode(data.toJson());

class Lapangan {
    final String id;
    final dynamic adminLapaganId; // ID admin, bisa String (UUID) atau int
    final String name;
    final String location;
    final String description;
    final double price; // DecimalField di Django di-map ke double di Dart
    final String? image; // URLField(null=True)
    final DateTime createdAt;
    final DateTime updatedAt;

    Lapangan({
        required this.id,
        required this.adminLapaganId,
        required this.name,
        required this.location,
        required this.description,
        required this.price,
        this.image,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Lapangan.fromJson(Map<String, dynamic> json) => Lapangan(
        id: json["id"].toString(),
        // admin_lapangan di-map ke tipe dinamis (int atau string)
        adminLapaganId: json["admin_lapangan"], 
        name: json["name"] as String,
        location: json["location"] as String,
        description: json["description"] as String,
        // Konversi tipe data numerik (int/String) dari JSON menjadi double
        price: (json["price"] as num).toDouble(), 
        image: json["image"] as String?,
        createdAt: DateTime.parse(json["created_at"] as String),
        updatedAt: DateTime.parse(json["updated_at"] as String),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "admin_lapangan": adminLapaganId,
        "name": name,
        "location": location,
        "description": description,
        "price": price,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}