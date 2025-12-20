class ForumResponse {
  final bool success;
  final String msg;
  final List<ForumData> data;

  ForumResponse({
    required this.success,
    required this.msg,
    required this.data,
  });

  factory ForumResponse.fromJson(Map<String, dynamic> json) {
    return ForumResponse(
      success: json["success"],
      msg: json["msg"],
      data: json["data"] != null
          ? List<ForumData>.from(json["data"].map((x) => ForumData.fromJson(x))) : [],
    );
  }
}

class ForumData {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final int? memberCount;
  final bool isMember;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumData({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    this.memberCount,
    required this.isMember,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumData.fromJson(Map<String, dynamic> json) {
    return ForumData(
      id: json["id"],
      creatorId: json["creator_id"],
      creatorName: json["creator_name"],
      title: json["title"],
      description: json["description"],
      memberCount: json['member_count'],
      isMember: json["is_member"] ?? false,
      createdAt: DateTime.tryParse(json["created_at"]) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"]) ?? DateTime.now(),
    );
  }
}