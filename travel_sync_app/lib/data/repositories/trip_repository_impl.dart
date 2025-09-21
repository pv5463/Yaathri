import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TripRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TripModel>>> getTrips({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      // Always try to get cached data first
      final cachedTrips = await localDataSource.getCachedTrips(userId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get fresh data from server
          final trips = await remoteDataSource.getTrips(
            userId,
            limit: limit,
            offset: offset,
          );
          
          // Cache the fresh data
          await localDataSource.cacheTrips(trips);
          return Right(trips);
        } on ServerException catch (e) {
          // If server fails, return cached data if available
          if (cachedTrips.isNotEmpty) {
            return Right(cachedTrips);
          }
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // No network, return cached data
        return Right(cachedTrips);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TripModel>> getTripById(String tripId) async {
    try {
      // Try to get from cache first
      final cachedTrip = await localDataSource.getCachedTrip(tripId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get fresh data from server
          final trip = await remoteDataSource.getTripById(tripId);
          
          // Cache the fresh data
          await localDataSource.cacheTrip(trip);
          return Right(trip);
        } on ServerException catch (e) {
          // If server fails, return cached data if available
          if (cachedTrip != null) {
            return Right(cachedTrip);
          }
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // No network, return cached data
        if (cachedTrip != null) {
          return Right(cachedTrip);
        }
        return const Left(NetworkFailure());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TripModel>> createTrip(TripModel trip) async {
    if (await networkInfo.isConnected) {
      try {
        final createdTrip = await remoteDataSource.createTrip(trip.toJson());
        await localDataSource.cacheTrip(createdTrip);
        return Right(createdTrip);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('create_trip', trip.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TripModel>> updateTrip(TripModel trip) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedTrip = await remoteDataSource.updateTrip(trip.id, trip.toJson());
        await localDataSource.cacheTrip(updatedTrip);
        return Right(updatedTrip);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('update_trip', trip.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTrip(tripId);
        await localDataSource.deleteCachedTrip(tripId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('delete_trip', {
        'id': tripId,
      });
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TripModel>> addLocationPoint({
    required String tripId,
    required LocationPoint locationPoint,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final trip = await remoteDataSource.addLocationPoint(tripId, locationPoint.toJson());
        await localDataSource.cacheTrip(trip);
        return Right(trip);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('add_location', {
        'trip_id': tripId,
        ...locationPoint.toJson(),
      });
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TripModel>> addTripMedia({
    required String tripId,
    required List<String> mediaUrls,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final trip = await remoteDataSource.addTripMedia(tripId, {'media_urls': mediaUrls});
        await localDataSource.cacheTrip(trip);
        return Right(trip);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('add_media', {
        'trip_id': tripId,
        'media_urls': mediaUrls,
      });
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TripModel>> removeTripMedia({
    required String tripId,
    required String mediaUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final trip = await remoteDataSource.removeTripMedia(tripId, mediaUrl);
        await localDataSource.cacheTrip(trip);
        return Right(trip);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('remove_media', {
        'trip_id': tripId,
        'media_url': mediaUrl,
      });
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<TripModel>>> syncTrips(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get pending sync data
        final pendingCreates = await localDataSource.getPendingSyncData('create_trip');
        final pendingUpdates = await localDataSource.getPendingSyncData('update_trip');
        final pendingDeletes = await localDataSource.getPendingSyncData('delete_trip');
        
        final syncData = {
          'user_id': userId,
          'creates': pendingCreates,
          'updates': pendingUpdates,
          'deletes': pendingDeletes,
        };
        
        final trips = await remoteDataSource.syncTrips(syncData);
        await localDataSource.cacheTrips(trips);
        
        // Clear pending sync data after successful sync
        await localDataSource.clearPendingSyncData('create_trip');
        await localDataSource.clearPendingSyncData('update_trip');
        await localDataSource.clearPendingSyncData('delete_trip');
        await localDataSource.clearPendingSyncData('add_location');
        await localDataSource.clearPendingSyncData('add_media');
        await localDataSource.clearPendingSyncData('remove_media');
        
        return Right(trips);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  // Helper methods for trip status management
  Future<Either<Failure, void>> startTrip({
    required String tripId,
  }) async {
    try {
      final cachedTrip = await localDataSource.getCachedTrip(tripId);
      if (cachedTrip != null) {
        final updatedTrip = cachedTrip.copyWith(
          status: TripStatus.inProgress,
          startTime: DateTime.now(),
        );
        return await updateTrip(updatedTrip).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      }
      return const Left(CacheFailure(message: 'Trip not found'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> endTrip({
    required String tripId,
  }) async {
    try {
      final cachedTrip = await localDataSource.getCachedTrip(tripId);
      if (cachedTrip != null) {
        final updatedTrip = cachedTrip.copyWith(
          status: TripStatus.completed,
          endTime: DateTime.now(),
        );
        return await updateTrip(updatedTrip).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      }
      return const Left(CacheFailure(message: 'Trip not found'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  Future<Either<Failure, void>> pauseTrip({
    required String tripId,
  }) async {
    try {
      final cachedTrip = await localDataSource.getCachedTrip(tripId);
      if (cachedTrip != null) {
        final updatedTrip = cachedTrip.copyWith(
          status: TripStatus.planned, // Using planned as paused equivalent
        );
        return await updateTrip(updatedTrip).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      }
      return const Left(CacheFailure(message: 'Trip not found'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> resumeTrip({
    required String tripId,
  }) async {
    try {
      final cachedTrip = await localDataSource.getCachedTrip(tripId);
      if (cachedTrip != null) {
        final updatedTrip = cachedTrip.copyWith(
          status: TripStatus.inProgress,
        );
        return await updateTrip(updatedTrip).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      }
      return const Left(CacheFailure(message: 'Trip not found'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
