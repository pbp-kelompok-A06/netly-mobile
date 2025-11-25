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
    });

    factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        location: json["location"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        imageUrl: json["image_url"] ?? "",          // null handling
        maxParticipants: json["max_participants"],
        participantCount: json["participant_count"] ?? 0, 
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "location": location,
        "start_date": "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "image_url": imageUrl,
        "max_participants": maxParticipants,
        "participant_count": participantCount,
    };
}