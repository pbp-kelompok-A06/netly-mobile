import 'dart:convert';

ForumResponse forumResponseFromJson(String str) => ForumResponse.fromJson(json.decode(str));
String forumResponseToJson(ForumResponse data) => json.encode(data.toJson());

class ForumResponse {
    bool success;
    String msg;
    List<ForumData> data;

    ForumResponse({
        required this.success,
        required this.msg,
        required this.data,
    });

    factory ForumResponse.fromJson(Map<String, dynamic> json) => ForumResponse(
        success: json["success"], 
        msg: json["msg"],
        data: List<ForumData>.from(json["data"].map((x) => ForumData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "sucesss": success,
        "msg": msg,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ForumData {
    String id;
    String creatorId;
    String creatorName;
    String title;
    String description;
    int? memberCount;
    bool? isMember;
    DateTime createdAt;
    DateTime updatedAt;

    ForumData({
        required this.id,
        required this.creatorId,
        required this.creatorName,
        required this.title,
        required this.description,
        this.memberCount,
        this.isMember,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ForumData.fromJson(Map<String, dynamic> json) => ForumData(
        id: json["id"],
        creatorId: json["creator_id"],
        creatorName: json["creator_name"],
        title: json["title"],
        description: json["description"],
        memberCount: json['member_count'],
        isMember: json["is_member"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => { 
        "title": title,
        "description": description,
    };
}