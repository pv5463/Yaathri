import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/monument_scanner_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import 'monument_result_screen.dart';

class MonumentScannerScreen extends StatefulWidget {
  const MonumentScannerScreen({super.key});

  @override
  State<MonumentScannerScreen> createState() => _MonumentScannerScreenState();
}

class _MonumentScannerScreenState extends State<MonumentScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _error;
  final MonumentScannerService _scannerService = MonumentScannerService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _scannerService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _error = null;
      });

      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission != PermissionStatus.granted) {
        setState(() {
          _error = 'Camera permission is required to scan monuments';
        });
        return;
      }

      // Initialize scanner service
      final scannerResult = await _scannerService.initialize();
      scannerResult.fold(
        (failure) {
          setState(() {
            _error = failure.message ?? 'Failed to initialize scanner';
          });
          return;
        },
        (_) {},
      );

      // Get available cameras
      final camerasResult = await _scannerService.getAvailableCameras();
      camerasResult.fold(
        (failure) {
          setState(() {
            _error = failure.message ?? 'No cameras available';
          });
          return;
        },
        (cameras) {
          _cameras = cameras;
        },
      );

      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found on this device';
        });
        return;
      }

      // Initialize camera controller with back camera
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      await _scanImage(image.path);
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _scanImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _scanImage(String imagePath) async {
    try {
      final result = await _scannerService.scanImage(imagePath);
      
      result.fold(
        (failure) {
          _showErrorSnackBar(failure.message ?? 'Failed to scan image');
        },
        (monumentInfo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonumentResultScreen(
                monumentInfo: monumentInfo,
              ),
            ),
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('Error scanning image: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Monument Scanner',
        showBackButton: true,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return const Center(
        child: LoadingWidget(message: 'Initializing camera...'),
      );
    }

    return Stack(
      children: [
        _buildCameraPreview(),
        _buildOverlay(),
        if (_isScanning) _buildScanningOverlay(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _initializeCamera,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox.expand(
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Text(
                  'Point camera at a monument and tap capture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: LoadingWidget(
          message: 'Scanning monument...',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'gallery',
          onPressed: _isScanning ? null : _pickFromGallery,
          backgroundColor: Colors.grey[800],
          child: const Icon(Icons.photo_library, color: Colors.white),
        ),
        FloatingActionButton.large(
          heroTag: 'capture',
          onPressed: _isScanning ? null : _captureAndScan,
          backgroundColor: Theme.of(context).primaryColor,
          child: _isScanning
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
        ),
        FloatingActionButton(
          heroTag: 'info',
          onPressed: _showInfoDialog,
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.info_outline, color: Colors.white),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monument Scanner'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to use:'),
            SizedBox(height: 8),
            Text('1. Point your camera at a monument'),
            Text('2. Tap the capture button'),
            Text('3. Wait for AI analysis'),
            Text('4. View monument information'),
            SizedBox(height: 16),
            Text('Supported monuments include famous Indian landmarks like Taj Mahal, Red Fort, India Gate, and more.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
