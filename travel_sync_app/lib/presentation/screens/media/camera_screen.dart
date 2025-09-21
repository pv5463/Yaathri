import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String _selectedMode = 'photo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
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
          ),
          
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
          onTap: _capturePhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
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

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  void _capturePhoto() {
    // Show capture animation
    _showCaptureAnimation();
    
    // Simulate photo capture
    Future.delayed(const Duration(milliseconds: 200), () {
      _showPhotoPreview();
    });
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

  void _showPhotoPreview() {
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
                  onPressed: () {
                    // Share photo
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
                child: const Center(
                  child: Icon(
                    Icons.photo,
                    size: 100,
                    color: Colors.white54,
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo saved successfully!'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
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
}
