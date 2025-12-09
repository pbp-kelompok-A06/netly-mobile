import 'dart:convert';

// --- FUNGSI HELPER PARSING JSON ---
List<Court> courtFromJson(String str) => List<Court>.from(json.decode(str)['results'].map((x) => Court.fromJson(x)));

List<Favorite> favoriteFromJson(String str) => List<Favorite>.from(json.decode(str)['results'].map((x) => Favorite.fromJson(x)));

class Court {
    String id;            
    String name;            
    double price;          
    String formattedPrice;  
    String location;        
    String image;           
    String description;     

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

        price: (json["price"] is int) 
            ? (json["price"] as int).toDouble() 
            : (json["price"] as double),
            
        formattedPrice: json["formatted_price"] ?? "",
        location: json["location"] ?? "-",
        image: json["image"] ?? "", 
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

class Favorite {
    String id;      
    int userId;     
    String label;    
    Court lapangan; 

    Favorite({
        required this.id,
        required this.userId,
        required this.label,
        required this.lapangan,
    });

    factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json["id"].toString(),
        userId: json["user_id"], 
        label: json["label"] ?? "Lainnya",

        lapangan: Court.fromJson(json["lapangan"]),
    );
}