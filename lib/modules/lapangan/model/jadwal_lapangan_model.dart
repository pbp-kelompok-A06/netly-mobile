// To parse this JSON data, do
//
//     final jadwalLapanganModel = jadwalLapanganModelFromJson(jsonString);

import 'dart:convert';

JadwalLapanganModel jadwalLapanganModelFromJson(String str) => JadwalLapanganModel.fromJson(json.decode(str));

String jadwalLapanganModelToJson(JadwalLapanganModel data) => json.encode(data.toJson());

class JadwalLapanganModel {
    String status;
    List<Datum> data;

    JadwalLapanganModel({
        required this.status,
        required this.data,
    });

    factory JadwalLapanganModel.fromJson(Map<String, dynamic> json) => JadwalLapanganModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    DateTime tanggal;
    String startMain;
    String endMain;
    bool isAvailable;

    Datum({
        required this.id,
        required this.tanggal,
        required this.startMain,
        required this.endMain,
        required this.isAvailable,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        tanggal: DateTime.parse(json["tanggal"]),
        startMain: json["start_main"],
        endMain: json["end_main"],
        isAvailable: json["is_available"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tanggal": "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "start_main": startMain,
        "end_main": endMain,
        "is_available": isAvailable,
    };
}
