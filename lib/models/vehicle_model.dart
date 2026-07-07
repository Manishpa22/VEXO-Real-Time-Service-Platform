import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String ownerId;
  final String type; // 'car' or 'bike'
  final String brand;
  final String model;
  final String color;
  final String numberPlate;
  final String? parkingSpot;
  final String? societyName;
  final String? imageUrl;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberPlate,
    this.parkingSpot,
    this.societyName,
    this.imageUrl,
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      type: data['type'] ?? 'car',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      color: data['color'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      parkingSpot: data['parkingSpot'],
      societyName: data['societyName'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'type': type,
      'brand': brand,
      'model': model,
      'color': color,
      'numberPlate': numberPlate,
      'parkingSpot': parkingSpot,
      'societyName': societyName,
      'imageUrl': imageUrl,
    };
  }
}
