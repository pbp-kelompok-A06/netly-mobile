import 'dart:convert';

PostResponse postResponseFromJson(String str) => PostResponse.fromJson(json.decode(str));
String postResponseToJson(PostResponse data) => json.encode(data.toJson());

class PostResponse {
    bool success;
    String msg;
    List<PostData> data;
    String? currentUserId;

    PostResponse({
        required this.success,
        required this.msg,
        required this.data,
        this.currentUserId,
    });

    factory PostResponse.fromJson(Map<String, dynamic> json) => PostResponse(
        success: json["success"],
        msg: json["msg"],
        data: List<PostData>.from(json["data"].map((x) => PostData.fromJson(x))),
        currentUserId: json["current_user_id"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "msg": msg,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class PostData {
    String id;
    String header;
    String content;
    DateTime createdAt;
    UserPost user;

    PostData({
        required this.id,
        required this.header,
        required this.content,
        required this.createdAt,
        required this.user,
    });

    factory PostData.fromJson(Map<String, dynamic> json) => PostData(
        id: json["id"],
        header: json["header"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        user: UserPost.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "header": header,
        "content": content,
    };
}

class UserPost {
    String id;
    String username;

    UserPost({
        required this.id,
        required this.username,
    });

    factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
    };
}