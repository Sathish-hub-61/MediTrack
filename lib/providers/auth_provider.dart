import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  String? _verificationId;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Constructor doesn't verify auth immediately
  AuthProvider();

  // Initialize called from SplashScreen
  Future<void> initialize() async {
    _auth = FirebaseAuth.instance;
    _auth!.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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
          await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // Additional user data can be stored in Firestore if needed
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
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
      final user = _auth!.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        if (email.isNotEmpty && user.email != email) {
          // Note: VerifyBeforeUpdateEmail might be needed in newer Firebase versions
          // For now, we try direct update or ignore if not supported for phone auth users without linking
          try {
            await user.verifyBeforeUpdateEmail(email);
          } catch (e) {
            debugPrint(
                'AuthProvider: Email update error (might need re-auth): $e');
          }
        }
        await user.reload();
        _user = _auth!.currentUser;
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
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
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
      if (_auth == null) {
        debugPrint('AuthProvider: _auth is null, re-initializing');
        _auth = FirebaseAuth.instance;
      }

      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('AuthProvider: verificationCompleted (Auto-resolution)');
          await _auth!.signInWithCredential(credential);
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
    } catch (e) {
      debugPrint('AuthProvider: verifyPhoneNumber Exception: $e');
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signInWithOTP(String smsCode) async {
    if (_verificationId == null) throw Exception("Verification ID is null");

    setLoading(true);
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth!.signInWithCredential(credential);
      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth!.signOut();
  }
}
