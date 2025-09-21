import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      AppConfig.cloudinaryCloudName,
      AppConfig.cloudinaryUploadPreset,
      cache: false,
    );
  }

  /// Upload image file to Cloudinary
  Future<CloudinaryResponse> uploadImage({
    required File imageFile,
    String? folder,
    Map<String, String>? tags,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? 'travel_sync',
          publicId: publicId,
          tags: tags?.values.toList(),
        ),
      );
      
      return response;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload image: $e');
    }
  }

  /// Upload image from bytes to Cloudinary
  Future<CloudinaryResponse> uploadImageFromBytes({
    required Uint8List imageBytes,
    required String fileName,
    String? folder,
    Map<String, String>? tags,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: fileName,
          folder: folder ?? 'travel_sync',
          publicId: publicId,
          tags: tags?.values.toList(),
        ),
      );
      
      return response;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload image: $e');
    }
  }

  /// Upload multiple images
  Future<List<CloudinaryResponse>> uploadMultipleImages({
    required List<File> imageFiles,
    String? folder,
    Map<String, String>? tags,
    Function(int, int)? onProgress,
  }) async {
    final responses = <CloudinaryResponse>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final response = await uploadImage(
          imageFile: imageFiles[i],
          folder: folder,
          tags: tags,
        );
        responses.add(response);
        
        onProgress?.call(i + 1, imageFiles.length);
      } catch (e) {
        // Continue with other uploads even if one fails
        print('Failed to upload image ${i + 1}: $e');
      }
    }
    
    return responses;
  }

  /// Upload video file to Cloudinary
  Future<CloudinaryResponse> uploadVideo({
    required File videoFile,
    String? folder,
    Map<String, String>? tags,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          folder: folder ?? 'travel_sync/videos',
          publicId: publicId,
          tags: tags?.values.toList(),
          resourceType: CloudinaryResourceType.Video,
        ),
      );
      
      return response;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload video: $e');
    }
  }

  /// Upload document (PDF, etc.) to Cloudinary
  Future<CloudinaryResponse> uploadDocument({
    required File documentFile,
    String? folder,
    Map<String, String>? tags,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          documentFile.path,
          folder: folder ?? 'travel_sync/documents',
          publicId: publicId,
          tags: tags?.values.toList(),
          resourceType: CloudinaryResourceType.Raw,
        ),
      );
      
      return response;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload document: $e');
    }
  }

  /// Delete media from Cloudinary
  Future<bool> deleteMedia({
    required String publicId,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Image,
  }) async {
    try {
      // Note: cloudinary_public doesn't support delete operations
      // This would typically be handled by your backend API
      throw UnimplementedError('Delete operations should be handled by backend API');
    } catch (e) {
      throw MediaException(message: 'Failed to delete media: $e');
    }
  }

  /// Generate optimized image URL
  String getOptimizedImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    // Create transformation parameters
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    transformations.add('c_$crop');
    
    final transformationString = transformations.join(',');
    return 'https://res.cloudinary.com/${AppConfig.cloudinaryCloudName}/image/upload/$transformationString/$publicId';
  }

  /// Generate thumbnail URL
  String getThumbnailUrl({
    required String publicId,
    int size = 150,
    String quality = 'auto',
  }) {
    return getOptimizedImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      quality: quality,
      crop: 'thumb',
    );
  }

  /// Upload trip media with specific folder structure
  Future<List<String>> uploadTripMedia({
    required String tripId,
    required List<XFile> mediaFiles,
    Function(int, int)? onProgress,
  }) async {
    final uploadedUrls = <String>[];
    
    for (int i = 0; i < mediaFiles.length; i++) {
      try {
        final file = File(mediaFiles[i].path);
        final isVideo = mediaFiles[i].path.toLowerCase().contains('.mp4') ||
                       mediaFiles[i].path.toLowerCase().contains('.mov');
        
        final response = isVideo
            ? await uploadVideo(
                videoFile: file,
                folder: 'travel_sync/trips/$tripId/videos',
                tags: {'trip_id': tripId, 'type': 'video'},
              )
            : await uploadImage(
                imageFile: file,
                folder: 'travel_sync/trips/$tripId/images',
                tags: {'trip_id': tripId, 'type': 'image'},
              );
        
        uploadedUrls.add(response.secureUrl);
        onProgress?.call(i + 1, mediaFiles.length);
      } catch (e) {
        print('Failed to upload media ${i + 1}: $e');
      }
    }
    
    return uploadedUrls;
  }

  /// Upload expense receipt
  Future<String?> uploadExpenseReceipt({
    required String expenseId,
    required File receiptFile,
  }) async {
    try {
      final response = await uploadImage(
        imageFile: receiptFile,
        folder: 'travel_sync/expenses/$expenseId',
        tags: {'expense_id': expenseId, 'type': 'receipt'},
      );
      
      return response.secureUrl;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload receipt: $e');
    }
  }

  /// Upload user profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final response = await uploadImage(
        imageFile: imageFile,
        folder: 'travel_sync/users/$userId',
        publicId: 'profile_image',
        tags: {'user_id': userId, 'type': 'profile'},
      );
      
      return response.secureUrl;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload profile image: $e');
    }
  }

  /// Upload travel document (passport, visa, etc.)
  Future<String?> uploadTravelDocument({
    required String userId,
    required File documentFile,
    required String documentType,
  }) async {
    try {
      final response = await uploadDocument(
        documentFile: documentFile,
        folder: 'travel_sync/users/$userId/documents',
        tags: {'user_id': userId, 'type': documentType, 'category': 'document'},
      );
      
      return response.secureUrl;
    } catch (e) {
      throw MediaUploadException(message: 'Failed to upload document: $e');
    }
  }

  /// Get media info from Cloudinary
  Future<Map<String, dynamic>?> getMediaInfo(String publicId) async {
    try {
      // Note: This would require admin API access
      // For now, return basic info from URL
      return {
        'public_id': publicId,
        'secure_url': _cloudinary.getImage(publicId).toString(),
        'resource_type': 'image',
      };
    } catch (e) {
      return null;
    }
  }

  /// Batch delete media
  Future<List<bool>> deleteMultipleMedia({
    required List<String> publicIds,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Image,
  }) async {
    final results = <bool>[];
    
    for (final publicId in publicIds) {
      try {
        final success = await deleteMedia(
          publicId: publicId,
          resourceType: resourceType,
        );
        results.add(success);
      } catch (e) {
        results.add(false);
      }
    }
    
    return results;
  }

  /// Generate signed upload URL for direct uploads
  String generateSignedUploadUrl({
    String? folder,
    Map<String, String>? tags,
    int? maxFileSize,
  }) {
    // This would require server-side signature generation
    // For now, return the basic upload URL
    return 'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload';
  }
}
