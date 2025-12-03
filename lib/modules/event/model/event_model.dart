import 'dart:convert';

List<EventEntry> eventEntryFromJson(String str) => List<EventEntry>.from(json.decode(str).map((x) => EventEntry.fromJson(x)));

String eventEntryToJson(List<EventEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventEntry {
    String id;
    String name;
    String description;
    String location;
    DateTime startDate;
    DateTime endDate;
    String imageUrl;
    int maxParticipants;
    int participantCount;
    bool isJoined;    // boolean untuk cek status participant udah join atau belum

    EventEntry({
        required this.id,
        required this.name,
        required this.description,
        required this.location,
        required this.startDate,
        required this.endDate,
        required this.imageUrl,
        required this.maxParticipants,
        required this.participantCount,
        required this.isJoined,
    });

    factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
        id: json["pk"],
        name: json["fields"]["name"], 
        description: json["fields"]["description"],
        location: json["fields"]["location"],
        startDate: DateTime.parse(json["fields"]["start_date"]),
        endDate: DateTime.parse(json["fields"]["end_date"]),
        imageUrl: json["fields"]["image_url"] ?? "",
        maxParticipants: json["fields"]["max_participants"],
        participantCount: json["fields"]["participant_count"] ?? 0,
        isJoined: json["fields"]["is_joined"] ?? false, // Ambil status join
    );

    Map<String, dynamic> toJson() => {
        "pk": id,
        "fields": {
            "name": name,
            "description": description,
            "location": location,
            "start_date": startDate.toIso8601String(),
            "end_date": endDate.toIso8601String(),
            "image_url": imageUrl,
            "max_participants": maxParticipants,
            "participant_count": participantCount,
            "is_joined": isJoined,
        }
    };
}