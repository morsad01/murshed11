class VehicleModel {
  final String id;
  final String ownerId;
  final String type;
  final String listingType;
  final String brand;
  final String model;
  final int year;
  final String? fuelType;
  final String? condition;
  final int mileage;
  final double? hourlyRate;
  final double? dailyRate;
  final double? salePrice;
  final double locationLat;
  final double locationLng;
  final String locationAddress;
  final bool insuranceAvailable;
  final double insuranceRate;
  final bool isAvailable;
  final double rating;
  final int totalBookings;
  final String description;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerName;
  final double? ownerRating;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.listingType,
    required this.brand,
    required this.model,
    required this.year,
    this.fuelType,
    this.condition,
    required this.mileage,
    this.hourlyRate,
    this.dailyRate,
    this.salePrice,
    required this.locationLat,
    required this.locationLng,
    required this.locationAddress,
    required this.insuranceAvailable,
    required this.insuranceRate,
    required this.isAvailable,
    required this.rating,
    required this.totalBookings,
    required this.description,
    required this.photoUrls,
    required this.createdAt,
    required this.updatedAt,
    this.ownerName,
    this.ownerRating,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['photo_urls'] != null) {
      photos = List<String>.from(json['photo_urls'] as List);
    } else if (json['vehicle_photos'] != null) {
      final photosList = json['vehicle_photos'] as List;
      photos = photosList.map((p) => p['photo_url'] as String).toList();
    }

    return VehicleModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      listingType: json['listing_type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      fuelType: json['fuel_type'] as String?,
      condition: json['condition'] as String?,
      mileage: json['mileage'] as int? ?? 0,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      dailyRate: (json['daily_rate'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      locationLat: (json['location_lat'] as num).toDouble(),
      locationLng: (json['location_lng'] as num).toDouble(),
      locationAddress: json['location_address'] as String,
      insuranceAvailable: json['insurance_available'] as bool? ?? false,
      insuranceRate: (json['insurance_rate'] as num?)?.toDouble() ?? 10.0,
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      photoUrls: photos,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerName: json['owner_name'] as String?,
      ownerRating: (json['owner_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'type': type,
      'listing_type': listingType,
      'brand': brand,
      'model': model,
      'year': year,
      'fuel_type': fuelType,
      'condition': condition,
      'mileage': mileage,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'sale_price': salePrice,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'location_address': locationAddress,
      'insurance_available': insuranceAvailable,
      'insurance_rate': insuranceRate,
      'is_available': isAvailable,
      'rating': rating,
      'total_bookings': totalBookings,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
