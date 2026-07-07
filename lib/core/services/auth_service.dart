import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';

// ─── Configuration ───────────────────────────────────────────────
// 🔧 SET THIS TO false WHEN YOUR MSG91 + BACKEND IS READY
const bool _demoMode = true;
const String _demoOtp = '123456';

// TODO: Change to your production server URL when deploying
const String _baseUrl = 'http://localhost:3001/api/auth'; // Web
// const String _baseUrl = 'http://10.0.2.2:3001/api/auth'; // Android emulator
// const String _baseUrl = 'https://your-server.com/api/auth'; // Production

// ─── Secure Storage for JWT ──────────────────────────────────────
const _storage = FlutterSecureStorage();
const _tokenKey = 'vexo_jwt_token';
const _userIdKey = 'vexo_user_id';
const _phoneKey = 'vexo_phone';

// ─── Providers ───────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

/// Auth state provider — checks if user is logged in via JWT
final authStateProvider = FutureProvider<String?>((ref) async {
  final token = await _storage.read(key: _tokenKey);
  if (token == null) return null;
  final userId = await _storage.read(key: _userIdKey);
  return userId;
});

/// Current user provider — streams the user's Firestore document
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (userId) {
      if (userId == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Auth Service ────────────────────────────────────────────────
class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  // ─── DEMO MODE: stored phone for verification ──────────────────
  String? _demoPhone;

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    // ── DEMO MODE ──────────────────────────────────────────────
    if (_demoMode) {
      _demoPhone = phone;
      debugPrint('🧪 DEMO MODE: OTP is $_demoOtp for +91$phone');
      await Future.delayed(const Duration(milliseconds: 800)); // simulate
      return true;
    }

    // ── PRODUCTION MODE ────────────────────────────────────────
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ OTP sent to +91$phone');
        return true;
      } else {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      debugPrint('❌ sendOtp error: $e');
      rethrow;
    }
  }

  /// Verify OTP and get JWT token
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    // ── DEMO MODE ──────────────────────────────────────────────
    if (_demoMode) {
      await Future.delayed(const Duration(milliseconds: 600)); // simulate

      if (otp != _demoOtp) {
        throw Exception('Invalid OTP. Demo OTP is: $_demoOtp');
      }

      // Create a demo user ID or find existing by phone
      String userId;
      bool isNewUser = false;

      // Check if user exists in Firestore by phone
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: '+91$phone')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        userId = existing.docs.first.id;
        debugPrint('🧪 DEMO: Existing user found: $userId');
      } else {
        userId = const Uuid().v4();
        isNewUser = true;
        debugPrint('🧪 DEMO: New user created: $userId');
      }

      // Store demo credentials
      await _storage.write(key: _tokenKey, value: 'demo_token_$userId');
      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _phoneKey, value: phone);

      // Invalidate providers to trigger rebuild
      _ref.invalidate(authStateProvider);
      _ref.invalidate(currentUserProvider);

      return {
        'userId': userId,
        'isNewUser': isNewUser,
        'token': 'demo_token_$userId',
      };
    }

    // ── PRODUCTION MODE ────────────────────────────────────────
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': phone, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userIdKey, value: data['userId']);
        await _storage.write(key: _phoneKey, value: phone);

        debugPrint('✅ OTP verified, JWT stored for user: ${data['userId']}');

        _ref.invalidate(authStateProvider);
        _ref.invalidate(currentUserProvider);

        return {
          'userId': data['userId'],
          'isNewUser': data['isNewUser'] ?? false,
          'token': data['token'],
        };
      } else {
        throw Exception(data['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('❌ verifyOtp error: $e');
      rethrow;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp(String phone) async {
    if (_demoMode) {
      debugPrint('🧪 DEMO MODE: OTP resent — use $_demoOtp');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ OTP resent to +91$phone');
        return true;
      }
      throw Exception(data['message'] ?? 'Failed to resend OTP');
    } catch (e) {
      debugPrint('❌ resendOtp error: $e');
      rethrow;
    }
  }

  /// Create or update user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String role,
    String? email,
    String? profileImageUrl,
  }) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    await userDoc.set(
      {
        'uid': uid,
        'name': name,
        'phone': phone,
        'role': role,
        'email': email ?? '',
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'referralCode': _generateReferralCode(),
      },
      SetOptions(merge: true),
    );
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('userExists check failed: $e');
      return false;
    }
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get stored phone
  Future<String?> getStoredPhone() async {
    return await _storage.read(key: _phoneKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  // ─── GOOGLE SIGN-IN ──────────────────────────────────────────
  /// Unified method to finalize login after a Firebase User is created
  Future<Map<String, dynamic>> _finalizeFirebaseUser(fb.UserCredential userCredential) async {
    final fb.User? user = userCredential.user;
    if (user == null) throw Exception('Google sign-in failed');

    // Check if user is new from Firebase Auth metadata. Default to true if unsure.
    bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;

    // Try checking Firestore with a longer timeout to avoid skipping profile creation on slow web loads
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      isNewUser = !userDoc.exists;
    } catch (e) {
      debugPrint('Firestore query timed out/failed ($e). Fallback to isNewUser: true to ensure profile creation.');
      isNewUser = true;
    }

    if (isNewUser) {
      // Create Firestore profile (non-blocking if it times out/fails)
      try {
        await createUserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          phone: user.phoneNumber ?? '',
          role: 'customer',
          email: user.email,
          profileImageUrl: user.photoURL,
        ).timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Failed to write profile immediately ($e). Queueing in background...');
        createUserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          phone: user.phoneNumber ?? '',
          role: 'customer',
          email: user.email,
          profileImageUrl: user.photoURL,
        ).catchError((err) {
          debugPrint('Background profile creation failed: $err');
        });
      }
    }

    // Store credentials in secure storage
    await _storage.write(key: _tokenKey, value: 'firebase_${user.uid}');
    await _storage.write(key: _userIdKey, value: user.uid);
    await _storage.write(key: _phoneKey, value: user.phoneNumber ?? '');

    debugPrint('✅ Google sign-in successful: ${user.uid}');

    _ref.invalidate(authStateProvider);
    _ref.invalidate(currentUserProvider);

    return {
      'userId': user.uid,
      'isNewUser': isNewUser,
      'name': user.displayName,
      'email': user.email,
    };
  }

  /// Sign in with an authenticated Google account (Mobile only)
  Future<Map<String, dynamic>> signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      final idToken = googleUser.authentication.idToken;
      final credential = fb.GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final fb.UserCredential userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      
      return _finalizeFirebaseUser(userCredential);
    } catch (e) {
      debugPrint('❌ Google sign-in account error: $e');
      rethrow;
    }
  }

  /// Master method for Google Sign-In button
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Native Firebase Auth Popup on Web guarantees Firebase Auth Sync!
        final provider = fb.GoogleAuthProvider();
        
        // This automatically creates the session in Firebase Auth
        final fb.UserCredential userCredential = 
            await fb.FirebaseAuth.instance.signInWithPopup(provider);
            
        return _finalizeFirebaseUser(userCredential);
      } else {
        // Mobile/Desktop flow via GoogleSignIn
        final googleSignIn = GoogleSignIn.instance;
        try {
          await googleSignIn.initialize();
        } catch (e) {
          debugPrint('Google Sign-In already initialized: $e');
        }
        final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
        return signInWithGoogleAccount(googleUser);
      }
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out — clear all stored credentials + Firebase + Google
  Future<void> signOut() async {
    try {
      await fb.FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _storage.deleteAll();
    _ref.invalidate(authStateProvider);
    _ref.invalidate(currentUserProvider);
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return 'VEXO${List.generate(6, (i) => chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length]).join()}';
  }
}

