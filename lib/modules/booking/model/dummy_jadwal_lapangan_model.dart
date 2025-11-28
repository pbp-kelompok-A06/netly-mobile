class Jadwal {
  final String id; 
  final DateTime tanggal;
  final String startMain;
  final String endMain;
  final bool isAvailable;

  Jadwal({
    required this.id,
    required this.tanggal,
    required this.startMain,
    required this.endMain,
    required this.isAvailable,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: "${json['tanggal']}_${json['start_main']}",   // fallback ID
      tanggal: DateTime.parse(json['tanggal']),
      startMain: json['start_main'],
      endMain: json['end_main'],
      isAvailable: json['is_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "tanggal": tanggal.toIso8601String().split('T')[0],
    "start_main": startMain,
    "end_main": endMain,
    "is_available": isAvailable,
  };
}
