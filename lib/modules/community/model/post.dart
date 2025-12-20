class PostResponse {
  final bool success;
  final String msg;
  final List<PostData> data;
  final String? currentUserId;

  PostResponse({
    required this.success,
    required this.msg,
    required this.data,
    this.currentUserId,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json["success"] ,
      msg: json["msg"],
      currentUserId: json["current_user_id"],
      data: json["data"] != null
          ? List<PostData>.from(json["data"].map((x) => PostData.fromJson(x))) : [],
    );
  }
}

class PostData {
  final String id;
  final String header;
  final String content;
  final DateTime createdAt;
  final UserPost user;
  final String forumName;

  PostData({
    required this.id,
    required this.header,
    required this.content,
    required this.createdAt,
    required this.user,
    required this.forumName,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      id: json["id"],
      header: json["header"],
      content: json["content"],
      forumName: json["forum_name"] ?? "General",
      createdAt: DateTime.tryParse(json["created_at"]) ?? DateTime.now(),
      user: UserPost.fromJson(json["user"]) ,
    );
  }
}

class UserPost {
  final String id;
  final String username;

  UserPost({
    required this.id,
    required this.username,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      id: json["id"],
      username: json["username"],
    );
  }

  
}