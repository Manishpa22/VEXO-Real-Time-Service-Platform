import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final String planName;
  final String planType; // 'basic', 'premium', 'yearly', 'two_wheeler'
  final double price;
  final String vehicleType; // 'car' or 'bike'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> features;
  final String? vehicleId;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planName,
    required this.planType,
    required this.price,
    required this.vehicleType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.features,
    this.vehicleId,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      planName: data['planName'] ?? '',
      planType: data['planType'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      vehicleType: data['vehicleType'] ?? 'car',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? false,
      features: List<String>.from(data['features'] ?? []),
      vehicleId: data['vehicleId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planName': planName,
      'planType': planType,
      'price': price,
      'vehicleType': vehicleType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'features': features,
      'vehicleId': vehicleId,
    };
  }
}
