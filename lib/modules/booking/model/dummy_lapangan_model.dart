// file: lapangan.dart
import 'dart:convert';

// Fungsi untuk mengkonversi JSON string ke objek Lapangan
Lapangan lapanganFromJson(String str) => Lapangan.fromJson(json.decode(str));

// Fungsi untuk mengkonversi objek Lapangan ke JSON string
String lapanganToJson(Lapangan data) => json.encode(data.toJson());

class Lapangan {
    final String id;
    
    final String name;
 
    final double price; // DecimalField di Django di-map ke double di Dart


    Lapangan({
        required this.id,
        required this.name,
        
        required this.price,

    });

factory Lapangan.fromJson(Map<String, dynamic> json) {
  return Lapangan(
    id: json['id'].toString(),
    name: json['name'],
    price: double.parse(json['price'].toString()),

  );
}


    Map<String, dynamic> toJson() => {
                  "id": id,
                  "name": name,
                  "price": price,

    };
}