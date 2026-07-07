import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/booking_model.dart';
import '../../models/subscription_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================== VEHICLES ==================

  Future<void> addVehicle(VehicleModel vehicle) async {
    await _db.collection('vehicles').doc(vehicle.id).set(vehicle.toFirestore());
    // Also add vehicle ID to user's vehicle list
    await _db.collection('users').doc(vehicle.ownerId).set({
      'vehicleIds': FieldValue.arrayUnion([vehicle.id]),
    }, SetOptions(merge: true));
  }

  Stream<List<VehicleModel>> getUserVehicles(String userId) {
    return _db
        .collection('vehicles')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VehicleModel.fromFirestore(doc)).toList());
  }

  Future<void> deleteVehicle(String vehicleId, String userId) async {
    await _db.collection('vehicles').doc(vehicleId).delete();
    await _db.collection('users').doc(userId).update({
      'vehicleIds': FieldValue.arrayRemove([vehicleId]),
    });
  }

  // ================== SUBSCRIPTIONS ==================

  Future<void> createSubscription(SubscriptionModel sub) async {
    await _db.collection('subscriptions').doc(sub.id).set(sub.toFirestore());
    await _db.collection('users').doc(sub.userId).update({
      'activeSubscriptionId': sub.id,
    });
  }

  Stream<SubscriptionModel?> getActiveSubscription(String userId) {
    return _db
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return SubscriptionModel.fromFirestore(snap.docs.first);
    });
  }

  Stream<List<SubscriptionModel>> getUserSubscriptions(String userId) {
    return _db
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc))
            .toList());
  }

  // ================== BOOKINGS ==================

  Future<void> createBooking(BookingModel booking) async {
    await _db
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toFirestore());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'completed') {
      updates['completedAt'] = Timestamp.fromDate(DateTime.now());
    }
    await _db.collection('bookings').doc(bookingId).update(updates);
  }

  Future<void> updateBookingPhotos(
      String bookingId, String? beforeUrl, String? afterUrl) async {
    final updates = <String, dynamic>{};
    if (beforeUrl != null) updates['beforePhotoUrl'] = beforeUrl;
    if (afterUrl != null) updates['afterPhotoUrl'] = afterUrl;
    await _db.collection('bookings').doc(bookingId).update(updates);
  }

  Future<void> rateBooking(
      String bookingId, double rating, String review) async {
    await _db.collection('bookings').doc(bookingId).update({
      'rating': rating,
      'review': review,
    });
  }

  Stream<List<BookingModel>> getCustomerBookings(String customerId) {
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  Stream<List<BookingModel>> getWorkerBookings(String workerId) {
    return _db
        .collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  Stream<List<BookingModel>> getWorkerTodayBookings(String workerId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _db
        .collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledDate', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  // ================== WORKER ==================

  Future<void> assignWorkerToBooking(
      String bookingId, String workerId, String workerName) async {
    await _db.collection('bookings').doc(bookingId).update({
      'workerId': workerId,
      'workerName': workerName,
      'status': 'assigned',
    });
  }

  Stream<Map<String, dynamic>> getWorkerStats(String workerId) {
    return _db
        .collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snap) {
      final bookings =
          snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      final completed =
          bookings.where((b) => b.status == 'completed').toList();
      final totalRating = completed
          .where((b) => b.rating != null)
          .fold<double>(0.0, (sum, b) => sum + b.rating!);
      final ratedCount = completed.where((b) => b.rating != null).length;

      return {
        'totalJobs': bookings.length,
        'completedJobs': completed.length,
        'pendingJobs': bookings.where((b) => b.status == 'pending' || b.status == 'assigned').length,
        'avgRating': ratedCount > 0 ? totalRating / ratedCount : 0.0,
        'totalEarnings': completed.length * 150.0, // ₹150 per job
      };
    });
  }

  // ================== USER PROFILE ==================

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    });
  }
}
