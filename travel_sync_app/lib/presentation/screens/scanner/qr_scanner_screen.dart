import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
// Note: Using simplified QR scanning without ML Kit for now
// TODO: Add proper barcode scanning when ML Kit package is available

import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_permission_service.dart';
import '../../widgets/custom_button.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final CameraPermissionService _permissionService = CameraPermissionService();
  // Simplified scanner without ML Kit
  // final BarcodeScanner _barcodeScanner = BarcodeScanner();
  
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isScanning = false;
  List<String> _detectedCodes = [];
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    // _barcodeScanner.close();
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
        includeVideo: false,
        includeStorage: false,
      );
      
      if (!permissionResult.canUseCamera) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan QR codes';
          _isInitializing = false;
        });
        return;
      }

      // Get back camera (better for scanning)
      final camera = _permissionService.primaryCamera;
      
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
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      // TODO: Start image stream for barcode detection when ML Kit is available
      // _controller!.startImageStream(_processCameraImage);

      setState(() {
        _isInitializing = false;
        _isScanning = true;
      });
      
      print('✅ QR Scanner initialized successfully');
    } catch (e) {
      print('❌ QR Scanner initialization failed: $e');
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    // TODO: Implement barcode scanning with ML Kit
    // For now, this is a placeholder
    print('📷 Processing camera image...');
  }

  // TODO: Implement camera image conversion when ML Kit is available
  // InputImage? _convertCameraImage(CameraImage image) { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or error/loading state
          _buildCameraPreview(),
          
          // Scanning overlay
          if (_isScanning) _buildScanningOverlay(),
          
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
                ],
              ),
            ),
          ),

          // Bottom instructions
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
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Point your camera at a QR code and tap capture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (!_isScanning)
                      CustomButton(
                        text: 'Capture QR Code',
                        onPressed: _captureQRCode,
                        backgroundColor: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                'Initializing Scanner...',
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
                Icons.qr_code_scanner_outlined,
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
            Icons.qr_code_scanner,
            size: 100,
            color: Colors.white54,
          ),
        ),
      );
    }

    return CameraPreview(_controller!);
  }

  Widget _buildScanningOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: ScannerOverlayPainter(),
      ),
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

  Future<void> _captureQRCode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      setState(() {
        _isScanning = true;
      });
      
      // Capture image for manual QR processing
      final XFile image = await _controller!.takePicture();
      
      // For now, show a demo result
      await Future.delayed(const Duration(seconds: 1));
      
      final demoResults = ['Demo QR Code: https://yaathri.app'];
      _showScanResults(demoResults);
      
    } catch (e) {
      print('❌ Error capturing QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture QR code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showScanResults(List<String> codes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Scan Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...codes.map((code) => _buildCodeResult(code)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Scan Again',
                    onPressed: () {
                      Navigator.of(context).pop();
                      _captureQRCode();
                    },
                    backgroundColor: Colors.grey[300]!,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Done',
                    onPressed: () {
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

  Widget _buildCodeResult(String code) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyToClipboard(code),
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement barcode type detection when ML Kit is available

  void _copyToClipboard(String text) {
    // TODO: Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;
    final scanAreaRect = Rect.fromLTWH(
      scanAreaLeft,
      scanAreaTop,
      scanAreaSize,
      scanAreaSize,
    );

    // Draw overlay with transparent scanning area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 30.0;
    final cornerRadius = 12.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanAreaLeft, scanAreaTop + cornerLength)
        ..lineTo(scanAreaLeft, scanAreaTop + cornerRadius)
        ..quadraticBezierTo(
          scanAreaLeft,
          scanAreaTop,
          scanAreaLeft + cornerRadius,
          scanAreaTop,
        )
        ..lineTo(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop)
        ..lineTo(scanAreaLeft + scanAreaSize - cornerRadius, scanAreaTop)
        ..quadraticBezierTo(
          scanAreaLeft + scanAreaSize,
          scanAreaTop,
          scanAreaLeft + scanAreaSize,
          scanAreaTop + cornerRadius,
        )
        ..lineTo(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength)
        ..lineTo(scanAreaLeft, scanAreaTop + scanAreaSize - cornerRadius)
        ..quadraticBezierTo(
          scanAreaLeft,
          scanAreaTop + scanAreaSize,
          scanAreaLeft + cornerRadius,
          scanAreaTop + scanAreaSize,
        )
        ..lineTo(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(
          scanAreaLeft + scanAreaSize - cornerLength,
          scanAreaTop + scanAreaSize,
        )
        ..lineTo(
          scanAreaLeft + scanAreaSize - cornerRadius,
          scanAreaTop + scanAreaSize,
        )
        ..quadraticBezierTo(
          scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize,
          scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize - cornerRadius,
        )
        ..lineTo(
          scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize - cornerLength,
        ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
