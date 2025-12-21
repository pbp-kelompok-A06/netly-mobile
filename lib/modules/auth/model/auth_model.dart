class AuthResponse {
  final String status;
  final String message;
  final UserProfile? data;

  AuthResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? UserProfile.fromJson(json['data']) : null
    );
  }
}

class UserProfile {
  final String id;
  final String username;
  final String fullname;
  final String role;
  final String? location; 
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullname,
    required this.role,
    this.location,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'], 
      username: json['username'],
      fullname: json['fullname'],
      role: json['role'],
      location: json['location'],
      profilePicture: json['profile_picture']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'fullname': fullname,
    'role': role,
    'location': location,
    'profile_picture': profilePicture
  };
}
