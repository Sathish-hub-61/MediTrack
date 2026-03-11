import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  String? _verificationId;
  ConfirmationResult? _confirmationResult;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _initialized;

  // Constructor doesn't verify auth immediately
  AuthProvider();

  // Initialize called from SplashScreen
  Future<void> initialize() async {
    try {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
      _initialized = true;
      debugPrint('AuthProvider: Initialized successfully');
    } catch (e) {
      debugPrint('AuthProvider: Initialization error: $e');
      _initialized = false;
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Ensure auth is available
  FirebaseAuth _getAuth() {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  // Email/Password Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    setLoading(true);
    try {
      final UserCredential credential =
          await _getAuth().createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);

        // Save user profile to Firestore so the pharmacy portal
        // can find this user by phone number and link medicines correctly
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint(
            'AuthProvider: User profile saved to Firestore with phone: $phone');
        await updateFCMToken();
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  // Link Email/Password to current Phone Auth user
  Future<void> linkEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    setLoading(true);
    try {
      final user = _getAuth().currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
            email: email, password: password);
        await user.linkWithCredential(credential);

        await user.updateDisplayName(name);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('AuthProvider: Linked email and phone successfully');
        await updateFCMToken();
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      debugPrint('AuthProvider: Link Error: $e');
      rethrow;
    }
  }

  // Update User Profile (Name/Email)
  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    setLoading(true);
    try {
      final user = _getAuth().currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        if (email.isNotEmpty && user.email != email) {
          try {
            await user.verifyBeforeUpdateEmail(email);
          } catch (e) {
            debugPrint(
                'AuthProvider: Email update error (might need re-auth): $e');
          }
        }
        await user.reload();
        _user = _getAuth().currentUser;
        notifyListeners();
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      debugPrint('AuthProvider: Update Profile Error: $e');
      rethrow;
    }
  }

  // Email/Password Sign In
  Future<void> signIn({required String email, required String password}) async {
    setLoading(true);
    try {
      final credential = await _getAuth()
          .signInWithEmailAndPassword(email: email, password: password);

      // Ensure the user profile exists in Firestore
      // This is critical for the pharmacy portal to find users by phone
      if (credential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Auto-create profile from Firebase Auth data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({
            'name': credential.user!.displayName ?? '',
            'email': credential.user!.email ?? email,
            'phone': credential.user!.phoneNumber ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          debugPrint(
              'AuthProvider: Auto-created Firestore profile for existing user');
        }
        await updateFCMToken();
      }

      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  // Phone Auth
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    debugPrint('AuthProvider: verifyPhoneNumber called for $phoneNumber');
    setLoading(true);
    try {
      if (kIsWeb) {
        // Web uses signInWithPhoneNumber which handles ReCAPTCHA automatically
        _confirmationResult =
            await _getAuth().signInWithPhoneNumber(phoneNumber);
        _verificationId = _confirmationResult!.verificationId;
        debugPrint(
            'AuthProvider: Web OTP Sent. Verification ID: $_verificationId');
        setLoading(false);
        onCodeSent(_verificationId!);
      } else {
        // Mobile uses native verifyPhoneNumber
        await _getAuth().verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint('AuthProvider: verificationCompleted (Auto-resolution)');
            await _getAuth().signInWithCredential(credential);
            setLoading(false);
            notifyListeners();
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint(
                'AuthProvider: verificationFailed: ${e.code} - ${e.message}');
            setLoading(false);
            onVerificationFailed(e);
          },
          codeSent: (String verificationId, int? resendToken) {
            debugPrint(
                'AuthProvider: codeSent. Verification ID: $verificationId');
            _verificationId = verificationId;
            setLoading(false);
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint('AuthProvider: codeAutoRetrievalTimeout');
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      debugPrint('AuthProvider: verifyPhoneNumber Exception: $e');
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signInWithOTP(String smsCode) async {
    if (_verificationId == null && !kIsWeb) {
      throw Exception("Verification ID is null");
    }

    setLoading(true);
    try {
      if (kIsWeb && _confirmationResult != null) {
        // Web confirmation
        await _confirmationResult!.confirm(smsCode);
      } else {
        // Mobile confirmation
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        );
        await _getAuth().signInWithCredential(credential);
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _getAuth().signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: SignOut error: $e');
    }
  }

  // --- FCM (Firebase Cloud Messaging) Logic ---
  Future<void> updateFCMToken() async {
    try {
      final user = _getAuth().currentUser;
      if (user == null) return;

      final messaging = FirebaseMessaging.instance;

      // 1. Request Permission (iOS/Web focus)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted notification permission');

        // 2. Get the specific Device Token
        String? token = await messaging.getToken();

        if (token != null) {
          debugPrint('FCM: Device Token captured: $token');

          // 3. Save to Firestore under the user doc
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fcmToken': token,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          debugPrint('FCM: Token successfully synced to database');
        }
      } else {
        debugPrint('FCM: User declined or restricted notification permissions');
      }
    } catch (e) {
      debugPrint('FCM: Error updating token: $e');
    }
  }
}
