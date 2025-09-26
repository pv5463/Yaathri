import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_permission_service.dart';
import '../../widgets/custom_button.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final CameraPermissionService _permissionService = CameraPermissionService();
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isScanning = false;
  bool _isFlashOn = false;
  List<String> _scannedDocuments = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
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
        includeStorage: true,
      );
      
      if (!permissionResult.canUseCamera) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan documents';
          _isInitializing = false;
        });
        return;
      }

      // Get back camera (better for document scanning)
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

      setState(() {
        _isInitializing = false;
      });
      
      print('✅ Document Scanner initialized successfully');
    } catch (e) {
      print('❌ Document Scanner initialization failed: $e');
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
          
          // Document scanning overlay
          _buildDocumentOverlay(),
          
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
                  if (_scannedDocuments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_scannedDocuments.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                    const Icon(
                      Icons.document_scanner,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position document within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery button
                        if (_scannedDocuments.isNotEmpty)
                          GestureDetector(
                            onTap: _showScannedDocuments,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),

                        // Capture button
                        GestureDetector(
                          onTap: _isScanning ? null : _captureDocument,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isScanning ? Colors.grey : Colors.white,
                                width: 4,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isScanning ? Colors.grey : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _isScanning
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
                                  : const Icon(
                                      Icons.document_scanner,
                                      color: Colors.black,
                                      size: 32,
                                    ),
                            ),
                          ),
                        ),

                        // Settings placeholder
                        const SizedBox(width: 60),
                      ],
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
                'Initializing Document Scanner...',
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
                Icons.document_scanner_outlined,
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
            Icons.document_scanner,
            size: 100,
            color: Colors.white54,
          ),
        ),
      );
    }

    return CameraPreview(_controller!);
  }

  Widget _buildDocumentOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: DocumentOverlayPainter(),
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

  Future<void> _captureDocument() async {
    if (_controller == null || !_controller!.value.isInitialized || _isScanning) {
      return;
    }

    try {
      setState(() {
        _isScanning = true;
      });

      // Capture the image
      final XFile image = await _controller!.takePicture();
      
      // Process the document with text recognition
      final recognizedText = await _processDocument(image.path);
      
      // Save the document
      await _saveDocument(image.path, recognizedText);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document scanned and saved successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
    } catch (e) {
      print('❌ Error capturing document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<String> _processDocument(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      print('❌ Error processing document: $e');
      return '';
    }
  }

  Future<void> _saveDocument(String imagePath, String recognizedText) async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Save image
      final imageFileName = 'document_$timestamp.jpg';
      final savedImagePath = path.join(directory.path, imageFileName);
      final File imageFile = File(imagePath);
      await imageFile.copy(savedImagePath);
      
      // Save text
      final textFileName = 'document_$timestamp.txt';
      final savedTextPath = path.join(directory.path, textFileName);
      final File textFile = File(savedTextPath);
      await textFile.writeAsString(recognizedText);
      
      setState(() {
        _scannedDocuments.add(savedImagePath);
      });
      
      print('✅ Document saved: $savedImagePath');
      print('✅ Text saved: $savedTextPath');
    } catch (e) {
      print('❌ Error saving document: $e');
      throw e;
    }
  }

  void _showScannedDocuments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Scanned Documents (${_scannedDocuments.length})',
                  style: const TextStyle(
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
            Expanded(
              child: ListView.builder(
                itemCount: _scannedDocuments.length,
                itemBuilder: (context, index) {
                  final documentPath = _scannedDocuments[index];
                  return _buildDocumentItem(documentPath, index);
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Done',
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String documentPath, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(documentPath),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scanned ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _shareDocument(documentPath),
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
        ],
      ),
    );
  }

  void _shareDocument(String documentPath) {
    // TODO: Implement document sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document sharing feature coming soon!'),
      ),
    );
  }
}

class DocumentOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create document frame (A4 ratio)
    final documentWidth = size.width * 0.8;
    final documentHeight = documentWidth * 1.414; // A4 ratio
    final documentLeft = (size.width - documentWidth) / 2;
    final documentTop = (size.height - documentHeight) / 2;
    final documentRect = Rect.fromLTWH(
      documentLeft,
      documentTop,
      documentWidth,
      documentHeight,
    );

    // Draw overlay with transparent document area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(documentRect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw document frame
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(documentRect, const Radius.circular(8)),
      framePaint,
    );

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(documentLeft, documentTop + cornerLength)
        ..lineTo(documentLeft, documentTop)
        ..lineTo(documentLeft + cornerLength, documentTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(documentLeft + documentWidth - cornerLength, documentTop)
        ..lineTo(documentLeft + documentWidth, documentTop)
        ..lineTo(documentLeft + documentWidth, documentTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(documentLeft, documentTop + documentHeight - cornerLength)
        ..lineTo(documentLeft, documentTop + documentHeight)
        ..lineTo(documentLeft + cornerLength, documentTop + documentHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(documentLeft + documentWidth - cornerLength, documentTop + documentHeight)
        ..lineTo(documentLeft + documentWidth, documentTop + documentHeight)
        ..lineTo(documentLeft + documentWidth, documentTop + documentHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
