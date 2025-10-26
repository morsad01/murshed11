class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String fullName;
  final String? profilePhoto;
  final String kycStatus;
  final String? nidCardUrl;
  final String? licenseUrl;
  final String? nidNumber;
  final String? licenseNumber;
  final double walletBalance;
  final double rating;
  final int totalReviews;
  final String languagePreference;
  final bool darkMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.fullName,
    this.profilePhoto,
    required this.kycStatus,
    this.nidCardUrl,
    this.licenseUrl,
    this.nidNumber,
    this.licenseNumber,
    required this.walletBalance,
    required this.rating,
    required this.totalReviews,
    required this.languagePreference,
    required this.darkMode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String? ?? '',
      profilePhoto: json['profile_photo'] as String?,
      kycStatus: json['kyc_status'] as String? ?? 'pending',
      nidCardUrl: json['nid_card_url'] as String?,
      licenseUrl: json['license_url'] as String?,
      nidNumber: json['nid_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      languagePreference: json['language_preference'] as String? ?? 'en',
      darkMode: json['dark_mode'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'kyc_status': kycStatus,
      'nid_card_url': nidCardUrl,
      'license_url': licenseUrl,
      'nid_number': nidNumber,
      'license_number': licenseNumber,
      'wallet_balance': walletBalance,
      'rating': rating,
      'total_reviews': totalReviews,
      'language_preference': languagePreference,
      'dark_mode': darkMode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? profilePhoto,
    String? kycStatus,
    String? nidCardUrl,
    String? licenseUrl,
    String? nidNumber,
    String? licenseNumber,
    double? walletBalance,
    double? rating,
    int? totalReviews,
    String? languagePreference,
    bool? darkMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      kycStatus: kycStatus ?? this.kycStatus,
      nidCardUrl: nidCardUrl ?? this.nidCardUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      nidNumber: nidNumber ?? this.nidNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      walletBalance: walletBalance ?? this.walletBalance,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      languagePreference: languagePreference ?? this.languagePreference,
      darkMode: darkMode ?? this.darkMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
