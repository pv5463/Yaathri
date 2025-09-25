import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

import '../error/failures.dart';
import '../error/exceptions.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Sign in with Google and return user credentials
  Future<Either<Failure, Map<String, dynamic>>> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In process...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return const Left(AuthFailure(message: 'Google Sign-In was cancelled'));
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        return const Left(AuthFailure(message: 'Failed to get Google authentication tokens'));
      }

      print('✅ Google authentication tokens obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print('❌ Firebase authentication failed');
        return const Left(AuthFailure(message: 'Firebase authentication failed'));
      }

      print('✅ Firebase authentication successful');

      // Get the Firebase ID token for backend authentication
      final String? idToken = await firebaseUser.getIdToken();

      if (idToken == null) {
        print('❌ Failed to get Firebase ID token');
        return const Left(AuthFailure(message: 'Failed to get Firebase ID token'));
      }

      // Return user data for backend authentication in the format expected by backend
      final userData = {
        'provider': 'google',
        'token': googleAuth.idToken, // Use Google ID token for verification
        'userData': {
          'email': firebaseUser.email,
          'name': firebaseUser.displayName,
          'picture': firebaseUser.photoURL,
          'id': firebaseUser.uid,
        },
        // Additional Firebase data for fallback
        'firebase_token': idToken,
        'access_token': googleAuth.accessToken,
      };

      print('✅ Google Sign-In completed successfully');
      return Right(userData);

    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or has expired.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign-In is not enabled for this project.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this credential.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification ID.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown Firebase error occurred.';
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
      
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
      
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
      final googleUser = await _googleSignIn.isSignedIn();
      final firebaseUser = _firebaseAuth.currentUser;
      return googleUser && firebaseUser != null;
    } catch (e) {
      print('❌ Error checking Google Sign-In status: $e');
      return false;
    }
  }

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Disconnect Google account (revoke access)
  Future<Either<Failure, void>> disconnect() async {
    try {
      print('🔐 Disconnecting Google account...');
      
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
      
      print('✅ Google account disconnected successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Google disconnect error: $e');
      return Left(AuthFailure(message: 'Failed to disconnect Google account: $e'));
    }
  }
}
