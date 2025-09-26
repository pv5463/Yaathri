import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraPermissionService {
  static final CameraPermissionService _instance = CameraPermissionService._internal();
  factory CameraPermissionService() => _instance;
  CameraPermissionService._internal();

  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  /// Initialize camera service and get available cameras
  Future<bool> initialize() async {
    try {
      print('📷 Initializing Camera Service...');
      
      if (_isInitialized) {
        return true;
      }

      // Get available cameras
      _cameras = await availableCameras();
      _isInitialized = true;
      
      print('✅ Camera Service initialized with ${_cameras?.length ?? 0} cameras');
      return true;
    } catch (e) {
      print('❌ Camera Service initialization failed: $e');
      return false;
    }
  }

  /// Get available cameras
  List<CameraDescription> get cameras => _cameras ?? [];

  /// Get primary camera (usually back camera)
  CameraDescription? get primaryCamera {
    if (_cameras == null || _cameras!.isEmpty) return null;
    
    // Try to find back camera first
    try {
      return _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } catch (e) {
      // If no back camera, return first available
      return _cameras!.first;
    }
  }

  /// Get front camera
  CameraDescription? get frontCamera {
    if (_cameras == null || _cameras!.isEmpty) return null;
    
    try {
      return _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check camera permission status
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      print('📷 Requesting camera permission...');
      
      final status = await Permission.camera.request();
      
      switch (status) {
        case PermissionStatus.granted:
          print('✅ Camera permission granted');
          return true;
        case PermissionStatus.denied:
          print('❌ Camera permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          print('❌ Camera permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          print('❌ Camera permission restricted');
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('❌ Error requesting camera permission: $e');
      return false;
    }
  }

  /// Check microphone permission (for video recording)
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }

  /// Request microphone permission (for video recording)
  Future<bool> requestMicrophonePermission() async {
    try {
      print('🎤 Requesting microphone permission...');
      
      final status = await Permission.microphone.request();
      
      switch (status) {
        case PermissionStatus.granted:
          print('✅ Microphone permission granted');
          return true;
        case PermissionStatus.denied:
          print('❌ Microphone permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          print('❌ Microphone permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          print('❌ Microphone permission restricted');
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Check storage permission (for saving photos/videos)
  Future<PermissionStatus> checkStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.storage.status;
    } else {
      return await Permission.photos.status;
    }
  }

  /// Request storage permission (for saving photos/videos)
  Future<bool> requestStoragePermission() async {
    try {
      print('💾 Requesting storage permission...');
      
      PermissionStatus status;
      if (defaultTargetPlatform == TargetPlatform.android) {
        status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }
      
      switch (status) {
        case PermissionStatus.granted:
          print('✅ Storage permission granted');
          return true;
        case PermissionStatus.denied:
          print('❌ Storage permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          print('❌ Storage permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          print('❌ Storage permission restricted');
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('❌ Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request all camera-related permissions
  Future<CameraPermissionResult> requestAllCameraPermissions({
    bool includeVideo = false,
    bool includeStorage = true,
  }) async {
    try {
      print('📷 Requesting all camera permissions...');
      
      // Always request camera permission
      final cameraGranted = await requestCameraPermission();
      
      // Request microphone permission if video recording is needed
      bool microphoneGranted = true;
      if (includeVideo) {
        microphoneGranted = await requestMicrophonePermission();
      }
      
      // Request storage permission if needed
      bool storageGranted = true;
      if (includeStorage) {
        storageGranted = await requestStoragePermission();
      }
      
      final result = CameraPermissionResult(
        cameraGranted: cameraGranted,
        microphoneGranted: microphoneGranted,
        storageGranted: storageGranted,
      );
      
      print('📷 Camera permissions result: ${result.toString()}');
      return result;
      
    } catch (e) {
      print('❌ Error requesting camera permissions: $e');
      return CameraPermissionResult(
        cameraGranted: false,
        microphoneGranted: false,
        storageGranted: false,
      );
    }
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      print('❌ Error opening app settings: $e');
      return false;
    }
  }

  /// Check if all required permissions are granted
  Future<bool> hasAllRequiredPermissions({
    bool includeVideo = false,
    bool includeStorage = true,
  }) async {
    try {
      final cameraStatus = await checkCameraPermission();
      bool cameraGranted = cameraStatus == PermissionStatus.granted;
      
      bool microphoneGranted = true;
      if (includeVideo) {
        final micStatus = await checkMicrophonePermission();
        microphoneGranted = micStatus == PermissionStatus.granted;
      }
      
      bool storageGranted = true;
      if (includeStorage) {
        final storageStatus = await checkStoragePermission();
        storageGranted = storageStatus == PermissionStatus.granted;
      }
      
      return cameraGranted && microphoneGranted && storageGranted;
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied. Please grant permission to continue.';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable in app settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted by device policy.';
      default:
        return 'Permission status unknown';
    }
  }
}

/// Result class for camera permission requests
class CameraPermissionResult {
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool storageGranted;

  const CameraPermissionResult({
    required this.cameraGranted,
    required this.microphoneGranted,
    required this.storageGranted,
  });

  /// Check if all requested permissions are granted
  bool get allGranted => cameraGranted && microphoneGranted && storageGranted;

  /// Check if camera permission is granted (minimum requirement)
  bool get canUseCamera => cameraGranted;

  /// Check if video recording is possible
  bool get canRecordVideo => cameraGranted && microphoneGranted;

  /// Check if saving media is possible
  bool get canSaveMedia => cameraGranted && storageGranted;

  @override
  String toString() {
    return 'CameraPermissionResult(camera: $cameraGranted, microphone: $microphoneGranted, storage: $storageGranted)';
  }
}
