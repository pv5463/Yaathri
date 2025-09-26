import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_permission_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final CameraPermissionService _permissionService = CameraPermissionService();
  
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String _selectedMode = 'photo';
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Initialize camera permission service
      await _permissionService.initialize();
      
      // Request camera permissions
      final permissionResult = await _permissionService.requestAllCameraPermissions(
        includeVideo: true,
        includeStorage: true,
      );
      
      if (!permissionResult.canUseCamera) {
        setState(() {
          _errorMessage = 'Camera permission is required to use this feature';
          _isInitializing = false;
        });
        return;
      }

      // Get camera
      final camera = _isFrontCamera 
          ? _permissionService.frontCamera 
          : _permissionService.primaryCamera;
      
      if (camera == null) {
        setState(() {
          _errorMessage = 'No camera available on this device';
          _isInitializing = false;
        });
        return;
      }

      // Initialize camera controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: _selectedMode == 'video',
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      setState(() {
        _isInitializing = false;
      });
      
      print('✅ Camera initialized successfully');
    } catch (e) {
      print('❌ Camera initialization failed: $e');
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or error/loading state
          _buildCameraPreview(),
          
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Open settings
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeSelector(),
                    const SizedBox(height: 24),
                    _buildCameraControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton('Photo', 'photo'),
        const SizedBox(width: 32),
        _buildModeButton('Video', 'video'),
        const SizedBox(width: 32),
        _buildModeButton('Panorama', 'panorama'),
      ],
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery button
        GestureDetector(
          onTap: () => context.push('/gallery'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white54),
            ),
            child: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // Capture button
        GestureDetector(
          onTap: _isCapturing ? null : _capturePhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isCapturing ? Colors.grey : Colors.white, 
                width: 4,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isCapturing ? Colors.grey : Colors.white,
                shape: BoxShape.circle,
              ),
              child: _isCapturing 
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Flip camera button
        GestureDetector(
          onTap: _flipCamera,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      final flashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(flashMode);
      
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('❌ Error toggling flash: $e');
    }
  }

  Future<void> _flipCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    
    // Reinitialize camera with new direction
    await _controller?.dispose();
    await _initializeCamera();
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                onPressed: _initializeCamera,
                backgroundColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Open Settings',
                onPressed: () => _permissionService.openAppSettings(),
                backgroundColor: Colors.white24,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            size: 100,
            color: Colors.white54,
          ),
        ),
      );
    }

    return CameraPreview(_controller!);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Show capture animation
      _showCaptureAnimation();
      
      // Capture the image
      final XFile image = await _controller!.takePicture();
      
      // Show photo preview
      await Future.delayed(const Duration(milliseconds: 200));
      _showPhotoPreview(image.path);
      
    } catch (e) {
      print('❌ Error capturing photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _showCaptureAnimation() {
    // Flash animation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      builder: (context) => Container(),
    );
    
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });
  }

  void _showPhotoPreview(String imagePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
                const Text(
                  'Photo Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    // TODO: Implement photo sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo sharing feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          size: 100,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Retake',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.white24,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Save',
                    onPressed: () async {
                      await _savePhoto(imagePath);
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePhoto(String imagePath) async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'yaathri_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(directory.path, fileName);
      
      // Copy the file to the app's directory
      final File imageFile = File(imagePath);
      await imageFile.copy(savedPath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo saved successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      print('✅ Photo saved to: $savedPath');
    } catch (e) {
      print('❌ Error saving photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
