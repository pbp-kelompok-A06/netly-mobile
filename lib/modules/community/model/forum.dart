import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
    bool sucesss;
    String msg;
    List<Datum> data;

    Forum({
        required this.sucesss,
        required this.msg,
        required this.data,
    });

    factory Forum.fromJson(Map<String, dynamic> json) => Forum(
        sucesss: json["sucesss"],
        msg: json["msg"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "sucesss": sucesss,
        "msg": msg,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    String creatorId;
    String title;
    String description;
    bool? isMember;
    DateTime createdAt;
    DateTime updatedAt;

    Datum({
        required this.id,
        required this.creatorId,
        required this.title,
        required this.description,
        this.isMember,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        creatorId: json["creator_id"],
        title: json["title"],
        description: json["description"],
        isMember: json["is_member"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "creator_id": creatorId,
        "title": title,
        "description": description,
        "is_member": isMember,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
