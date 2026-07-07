import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String? workerId;
  final String vehicleId;
  final String vehicleType;
  final String status; // 'pending', 'assigned', 'en_route', 'in_progress', 'completed', 'cancelled'
  final DateTime scheduledDate;
  final String? timeSlot;
  final String address;
  final String? societyName;
  final String? parkingSpot;
  final List<String> services;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? workerName;
  final String? customerName;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehicleNumberPlate;

  BookingModel({
    required this.id,
    required this.customerId,
    this.workerId,
    required this.vehicleId,
    required this.vehicleType,
    required this.status,
    required this.scheduledDate,
    this.timeSlot,
    required this.address,
    this.societyName,
    this.parkingSpot,
    required this.services,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.rating,
    this.review,
    required this.createdAt,
    this.completedAt,
    this.workerName,
    this.customerName,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleNumberPlate,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      workerId: data['workerId'],
      vehicleId: data['vehicleId'] ?? '',
      vehicleType: data['vehicleType'] ?? 'car',
      status: data['status'] ?? 'pending',
      scheduledDate:
          (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'],
      address: data['address'] ?? '',
      societyName: data['societyName'],
      parkingSpot: data['parkingSpot'],
      services: List<String>.from(data['services'] ?? []),
      beforePhotoUrl: data['beforePhotoUrl'],
      afterPhotoUrl: data['afterPhotoUrl'],
      rating: data['rating']?.toDouble(),
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      workerName: data['workerName'],
      customerName: data['customerName'],
      vehicleBrand: data['vehicleBrand'],
      vehicleModel: data['vehicleModel'],
      vehicleColor: data['vehicleColor'],
      vehicleNumberPlate: data['vehicleNumberPlate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'workerId': workerId,
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'status': status,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'address': address,
      'societyName': societyName,
      'parkingSpot': parkingSpot,
      'services': services,
      'beforePhotoUrl': beforePhotoUrl,
      'afterPhotoUrl': afterPhotoUrl,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'workerName': workerName,
      'customerName': customerName,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleNumberPlate': vehicleNumberPlate,
    };
  }

  BookingModel copyWith({
    String? status,
    String? workerId,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
    double? rating,
    String? review,
    DateTime? completedAt,
    String? workerName,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      workerId: workerId ?? this.workerId,
      vehicleId: vehicleId,
      vehicleType: vehicleType,
      status: status ?? this.status,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      address: address,
      societyName: societyName,
      parkingSpot: parkingSpot,
      services: services,
      beforePhotoUrl: beforePhotoUrl ?? this.beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      workerName: workerName ?? this.workerName,
      customerName: customerName,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      vehicleNumberPlate: vehicleNumberPlate,
    );
  }
}
