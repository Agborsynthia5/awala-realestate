class Property {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String type; // room, studio, apartment, villa
  final double price;
  final String currency;
  final bool furnished;
  final int bedrooms;
  final int bathrooms;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? neighborhood;
  final String city;
  final List<String> amenities;
  final List<String> images;
  final bool isActive;
  final bool isVerified;
  final int viewCount;
  final double? distanceFromMolykoKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.type,
    required this.price,
    required this.currency,
    required this.furnished,
    required this.bedrooms,
    required this.bathrooms,
    this.locationName,
    this.latitude,
    this.longitude,
    this.neighborhood,
    required this.city,
    required this.amenities,
    required this.images,
    required this.isActive,
    required this.isVerified,
    required this.viewCount,
    this.distanceFromMolykoKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.parse(json['price'].toString()),
      currency: json['currency'] as String? ?? 'XAF',
      furnished: json['furnished'] as bool? ?? false,
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      locationName: json['location_name'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String? ?? 'Buea',
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      distanceFromMolykoKm: (json['distance_from_molyko_km'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'type': type,
      'price': price,
      'currency': currency,
      'furnished': furnished,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'neighborhood': neighborhood,
      'city': city,
      'amenities': amenities,
      'images': images,
      'is_active': isActive,
      'is_verified': isVerified,
      'view_count': viewCount,
      'distance_from_molyko_km': distanceFromMolykoKm,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
