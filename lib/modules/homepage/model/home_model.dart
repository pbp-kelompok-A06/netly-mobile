import 'dart:convert';

// --- FUNGSI HELPER PARSING JSON ---
List<Court> courtFromJson(String str) => List<Court>.from(json.decode(str)['results'].map((x) => Court.fromJson(x)));

List<Favorite> favoriteFromJson(String str) => List<Favorite>.from(json.decode(str)['results'].map((x) => Favorite.fromJson(x)));

// ==========================================
// 1. MODEL COURT (Sesuai serialize_lapangan)
// ==========================================
class Court {
    String id;              // Django: str(obj.id) -> UUID String
    String name;            // Django: obj.name
    double price;           // Django: float(obj.price)
    String formattedPrice;  // Django: "50.000" (String)
    String location;        // Django: obj.location
    String image;           // Django: obj.image.url (Relative Path)
    String description;     // Django: obj.description

    Court({
        required this.id,
        required this.name,
        required this.price,
        required this.formattedPrice,
        required this.location,
        required this.image,
        required this.description,
    });

    factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json["id"].toString(), 
        name: json["name"] ?? "Tanpa Nama",
        
        // Handle konversi aman ke Double (karena kadang JSON anggap int sebagai int, bukan float)
        price: (json["price"] is int) 
            ? (json["price"] as int).toDouble() 
            : (json["price"] as double),
            
        formattedPrice: json["formatted_price"] ?? "",
        location: json["location"] ?? "-",
        image: json["image"] ?? "", // Nanti ditambah URL di Widget
        description: json["description"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "formatted_price": formattedPrice,
        "location": location,
        "image": image,
        "description": description,
    };
}

// ================================================
// 2. MODEL FAVORITE (Sesuai serialize_favorite_item)
// ================================================
class Favorite {
    String id;       // Django: str(fav.id)
    int userId;      // Django: fav.user.id (Integer)
    String label;    // Django: fav.label ("Rumah", "Kantor", dll)
    Court lapangan;  // Django: Nested Object "lapangan": {...}

    Favorite({
        required this.id,
        required this.userId,
        required this.label,
        required this.lapangan,
    });

    factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json["id"].toString(),
        userId: json["user_id"], // Integer
        label: json["label"] ?? "Lainnya",
        
        // PENTING: Parsing object di dalam object (Nested)
        // Kita gunakan Court.fromJson untuk memproses data 'lapangan'
        lapangan: Court.fromJson(json["lapangan"]),
    );
}