// To parse this JSON data, do
//
//     final lapanganModel = lapanganModelFromJson(jsonString);

import 'dart:convert';

LapanganModel lapanganModelFromJson(String str) => LapanganModel.fromJson(json.decode(str));

String lapanganModelToJson(LapanganModel data) => json.encode(data.toJson());

class LapanganModel {
    String status;
    List<Datum> data;

    LapanganModel({
        required this.status,
        required this.data,
    });

    factory LapanganModel.fromJson(Map<String, dynamic> json) => LapanganModel(
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
    String name;
    String location;
    String description;
    int price;
    String image;
    String adminName;

    Datum({
        required this.id,
        required this.name,
        required this.location,
        required this.description,
        required this.price,
        required this.image,
        required this.adminName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        location: json["location"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        adminName: json["admin_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "description": description,
        "price": price,
        "image": image,
        "admin_name": adminName,
    };
}