// file: jadwal_lapangan.dart
import 'dart:convert';

// Fungsi untuk mengkonversi JSON string ke list Jadwal
List<Jadwal> jadwalFromJson(String str) => 
    List<Jadwal>.from(json.decode(str).map((x) => Jadwal.fromJson(x)));

// Fungsi untuk mengkonversi list Jadwal ke JSON string
String jadwalToJson(List<Jadwal> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Jadwal {
    final String id;
    final String lapanganId; // Foreign Key Lapangan (UUID)
    final DateTime tanggal; // DateField di-map ke DateTime
    final String startMain; // TimeField di-map ke String (misal: "10:00:00")
    final String endMain;   // TimeField di-map ke String
    final bool isAvailable;

    Jadwal({
        required this.id,
        required this.lapanganId,
        required this.tanggal,
        required this.startMain,
        required this.endMain,
        required this.isAvailable,
    });

    factory Jadwal.fromJson(Map<String, dynamic> json) => Jadwal(
        id: json["id"].toString(),
        // Asumsi Lapangan dikirim sebagai ID UUID
        lapanganId: json["lapangan"] is String ? json["lapangan"] : json["lapangan"].toString(), 
        // Parsing hanya tanggal, bukan waktu lengkap
        tanggal: DateTime.parse(json["tanggal"] as String),
        startMain: json["start_main"] as String,
        endMain: json["end_main"] as String,
        isAvailable: json["is_available"] as bool,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "lapangan": lapanganId,
        // Menggunakan toIso8601String() dan mengambil bagian tanggal saja, 
        // atau pastikan backend menerima format YYYY-MM-DD
        "tanggal": tanggal.toIso8601String().split('T')[0], 
        "start_main": startMain,
        "end_main": endMain,
        "is_available": isAvailable,
    };
}