import 'package:google_sign_in/google_sign_in.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../error/failures.dart';
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;
  Future<bool> initialize() async {
    try {
      print('🔧 Initializing Google Sign-In service...');
      
      if (!_isInitialized) {
        await _googleSignIn.initialize();
        _isInitialized = true;
        print('✅ Google Sign-In SDK initialized');
      }
      
      // Check current Google user
      print('🔍 Checking for existing Google user...');
      
      // Try to get current user silently
      await _attemptSilentSignIn();
      
      print('✅ Google Sign-In service initialized successfully');
      return true;
    } catch (e) {
      print('❌ Google Sign-In initialization failed: $e');
      return false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _attemptSilentSignIn() async {
    try {
      final result = _googleSignIn.attemptLightweightAuthentication();
      if (result is Future<GoogleSignInAccount?>) {
        _currentUser = await result;
      } else {
        _currentUser = result as GoogleSignInAccount?;
      }
      if (_currentUser != null) {
        print('✅ Silent sign-in successful: ${_currentUser!.email}');
      }
    } catch (e) {
      print('ℹ️ Silent sign-in not available: $e');
      _currentUser = null;
    }
  }

  /// Sign in with Google and return user credentials
  Future<Either<Failure, Map<String, dynamic>>> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In process...');
      
      await _ensureInitialized();
      
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      _currentUser = googleUser;
      
      print('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request (now synchronous in v7)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        return const Left(AuthFailure(message: 'Failed to get authentication tokens'));
      }

      print('✅ Google authentication tokens obtained');

      // Return user data for backend authentication
      final userData = {
        'provider': 'google',
        'token': googleAuth.idToken, // Use Google ID token for verification
        'userData': {
          'email': googleUser.email,
          'name': googleUser.displayName,
          'picture': googleUser.photoUrl,
          'id': googleUser.id,
        },
        'access_token': '', // Access token not available in Google Sign-In v7
      };

      print('✅ Google Sign-In completed successfully');
      return Right(userData);

    } on PlatformException catch (e) {
      print('❌ Google Sign-In Platform Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'sign_in_canceled':
          errorMessage = 'Google Sign-In was cancelled by user.';
          break;
        case 'network_error':
          errorMessage = 'Network error occurred during Google Sign-In.';
          break;
        case 'sign_in_required':
          errorMessage = 'Sign-in is required to continue.';
          break;
        case 'sign_in_failed':
          errorMessage = 'Google Sign-In failed. Please try again.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown Google Sign-In error occurred.';
      }
      return Left(AuthFailure(message: errorMessage));
    } catch (e) {
      print('❌ Unexpected Google Sign-In error: $e');
      return Left(AuthFailure(message: 'An unexpected error occurred during Google Sign-In: $e'));
    }
  }

  /// Sign out from Google and Firebase
  Future<Either<Failure, void>> signOut() async {
    try {
      print('🔐 Starting Google Sign-Out process...');
      
      await _ensureInitialized();
      
      await _googleSignIn.signOut();
      
      _currentUser = null;
      
      print('✅ Google Sign-Out completed successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Google Sign-Out error: $e');
      return Left(AuthFailure(message: 'Failed to sign out: $e'));
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    try {
      await _ensureInitialized();
      return _currentUser != null;
    } catch (e) {
      print('❌ Error checking Google Sign-In status: $e');
      return false;
    }
  }

  /// Get current Google user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      await _ensureInitialized();
      
      // Return cached user if available
      if (_currentUser != null) {
        return _currentUser;
      }
      
      // Try silent authentication
      await _attemptSilentSignIn();
      return _currentUser;
    } catch (e) {
      print('❌ Error getting current Google user: $e');
      return null;
    }
  }

  /// Get current Google user synchronously (may be null if not cached)
  GoogleSignInAccount? get currentUserSync {
    return _currentUser;
  }


  /// Disconnect Google account (revoke access)
  Future<Either<Failure, void>> disconnect() async {
    try {
      print('🔐 Disconnecting Google account...');
      
      await _ensureInitialized();
      
      await _googleSignIn.disconnect();
      
      _currentUser = null;
      
      print('✅ Google account disconnected successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Google disconnect error: $e');
      return Left(AuthFailure(message: 'Failed to disconnect Google account: $e'));
    }
  }
}
