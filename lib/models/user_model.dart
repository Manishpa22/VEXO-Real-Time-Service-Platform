import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'customer' or 'worker'
  final String gender; // 'male', 'female', 'other'
  final String? profileImageUrl;
  final String? address;
  final DateTime createdAt;
  final List<String> vehicleIds;
  final String? activeSubscriptionId;
  final String? referralCode;
  final double walletBalance;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email = '',
    required this.role,
    this.gender = 'male',
    this.profileImageUrl,
    this.address,
    required this.createdAt,
    this.vehicleIds = const [],
    this.activeSubscriptionId,
    this.referralCode,
    this.walletBalance = 0.0,
  });

  /// Indicates if the profile has all required fields filled (e.g. skipped Google Sign-in setup)
  bool get isProfileComplete => name.isNotEmpty && phone.isNotEmpty;

  /// Initials from the user's name (e.g. "Rahul Sharma" → "RS")
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      gender: data['gender'] ?? 'male',
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vehicleIds: List<String>.from(data['vehicleIds'] ?? []),
      activeSubscriptionId: data['activeSubscriptionId'],
      referralCode: data['referralCode'],
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'vehicleIds': vehicleIds,
      'activeSubscriptionId': activeSubscriptionId,
      'referralCode': referralCode,
      'walletBalance': walletBalance,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? role,
    String? gender,
    String? profileImageUrl,
    String? address,
    List<String>? vehicleIds,
    String? activeSubscriptionId,
    String? referralCode,
    double? walletBalance,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      activeSubscriptionId: activeSubscriptionId ?? this.activeSubscriptionId,
      referralCode: referralCode ?? this.referralCode,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
