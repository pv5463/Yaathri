import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

import '../../data/models/trip_model.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _currentTripId;
  Position? _lastKnownPosition;
  final StreamController<LocationPoint> _locationController = 
      StreamController<LocationPoint>.broadcast();

  Stream<LocationPoint> get locationStream => _locationController.stream;

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      if (!await isLocationServiceEnabled()) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      return _lastKnownPosition;
    }
  }

  /// Start location tracking for a trip
  Future<void> startLocationTracking(String tripId) async {
    _currentTripId = tripId;
    
    if (!await hasLocationPermission()) {
      throw Exception('Location permission not granted');
    }

    if (!await isLocationServiceEnabled()) {
      throw Exception('Location service not enabled');
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _onLocationUpdate(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _currentTripId = null;
  }

  /// Handle location updates
  void _onLocationUpdate(Position position) {
    if (_currentTripId == null) return;

    final locationPoint = LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
    );

    _locationController.add(locationPoint);
    _lastKnownPosition = position;
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate total distance for a route
  double calculateRouteDistance(List<LocationPoint> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  /// Check if user is moving (speed threshold)
  bool isUserMoving(Position position) {
    const double speedThreshold = 1.0; // m/s (approximately 3.6 km/h)
    return position.speed > speedThreshold;
  }

  /// Detect if user has stopped at a location
  bool hasUserStopped(List<LocationPoint> recentPoints) {
    if (recentPoints.length < 3) return false;

    const double radiusThreshold = 50.0; // meters
    const int timeThreshold = 300; // 5 minutes in seconds

    final latestPoint = recentPoints.last;
    final oldestPoint = recentPoints.first;

    // Check if user has been in the same area for a while
    final distance = calculateDistance(
      latestPoint.latitude,
      latestPoint.longitude,
      oldestPoint.latitude,
      oldestPoint.longitude,
    );

    final timeDifference = latestPoint.timestamp
        .difference(oldestPoint.timestamp)
        .inSeconds;

    return distance < radiusThreshold && timeDifference > timeThreshold;
  }

  /// Auto-detect trip start based on movement
  bool shouldStartTrip(List<LocationPoint> recentPoints) {
    if (recentPoints.length < 2) return false;

    const double movementThreshold = 100.0; // meters
    const int timeWindow = 60; // 1 minute in seconds

    final latestPoint = recentPoints.last;
    final earlierPoint = recentPoints.first;

    final distance = calculateDistance(
      latestPoint.latitude,
      latestPoint.longitude,
      earlierPoint.latitude,
      earlierPoint.longitude,
    );

    final timeDifference = latestPoint.timestamp
        .difference(earlierPoint.timestamp)
        .inSeconds;

    return distance > movementThreshold && timeDifference <= timeWindow;
  }

  /// Auto-detect trip end based on stopping
  bool shouldEndTrip(List<LocationPoint> recentPoints) {
    return hasUserStopped(recentPoints);
  }

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Check if currently tracking
  bool get isTracking => _positionStreamSubscription != null;

  /// Get current trip ID being tracked
  String? get currentTripId => _currentTripId;

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}
