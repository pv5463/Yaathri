import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/services.dart';
import 'package:dartz/dartz.dart';

import '../error/failures.dart';

class MonumentInfo {
  final String name;
  final String description;
  final String category;
  final double confidence;
  final List<String> detectedText;
  final List<String> detectedLabels;
  final String? imagePath;

  MonumentInfo({
    required this.name,
    required this.description,
    required this.category,
    required this.confidence,
    required this.detectedText,
    required this.detectedLabels,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category,
    'confidence': confidence,
    'detectedText': detectedText,
    'detectedLabels': detectedLabels,
    'imagePath': imagePath,
  };
}

class MonumentScannerService {
  static final MonumentScannerService _instance = MonumentScannerService._internal();
  factory MonumentScannerService() => _instance;
  MonumentScannerService._internal();

  late TextRecognizer _textRecognizer;
  late ImageLabeler _imageLabeler;
  late ObjectDetector _objectDetector;
  bool _isInitialized = false;

  // Monument database - In a real app, this would come from a server or local database
  static const Map<String, Map<String, dynamic>> _monumentDatabase = {
    'taj_mahal': {
      'name': 'Taj Mahal',
      'description': 'An ivory-white marble mausoleum on the right bank of the river Yamuna in Agra, Uttar Pradesh, India. It was commissioned in 1631 by the Mughal emperor Shah Jahan to house the tomb of his favourite wife, Mumtaz Mahal.',
      'category': 'Mausoleum',
      'keywords': ['taj', 'mahal', 'agra', 'marble', 'mausoleum', 'shah jahan', 'mumtaz'],
      'labels': ['building', 'architecture', 'monument', 'dome', 'marble'],
    },
    'red_fort': {
      'name': 'Red Fort (Lal Qila)',
      'description': 'A historic fortified palace of the Mughal emperors of India located in Old Delhi. It served as the main residence of the Mughal emperors for nearly 200 years.',
      'category': 'Fort',
      'keywords': ['red', 'fort', 'lal', 'qila', 'delhi', 'mughal', 'palace'],
      'labels': ['building', 'fort', 'architecture', 'red', 'wall'],
    },
    'india_gate': {
      'name': 'India Gate',
      'description': 'A war memorial located near the Rajpath on the eastern edge of the "ceremonial axis" of New Delhi. It stands as a memorial to 70,000 soldiers of the British Indian Army who died in the period 1914–21.',
      'category': 'War Memorial',
      'keywords': ['india', 'gate', 'memorial', 'delhi', 'war', 'soldiers'],
      'labels': ['monument', 'gate', 'memorial', 'arch', 'stone'],
    },
    'qutub_minar': {
      'name': 'Qutub Minar',
      'description': 'A minaret and "victory tower" that forms part of the Qutb complex, a UNESCO World Heritage Site in the Mehrauli area of New Delhi, India.',
      'category': 'Minaret',
      'keywords': ['qutub', 'qutb', 'minar', 'minaret', 'delhi', 'tower', 'unesco'],
      'labels': ['tower', 'minaret', 'building', 'stone', 'architecture'],
    },
    'lotus_temple': {
      'name': 'Lotus Temple',
      'description': 'A Baháʼí House of Worship in New Delhi, India. Notable for its flowerlike shape, it has become a prominent attraction in the city.',
      'category': 'Temple',
      'keywords': ['lotus', 'temple', 'bahai', 'delhi', 'flower', 'worship'],
      'labels': ['building', 'temple', 'lotus', 'white', 'architecture'],
    },
    'gateway_of_india': {
      'name': 'Gateway of India',
      'description': 'An arch-monument built in the early 20th century in the city of Mumbai, India. It was erected to commemorate the landing of King-Emperor George V and Queen-Empress Mary at Apollo Bunder on their visit to India in 1911.',
      'category': 'Monument',
      'keywords': ['gateway', 'india', 'mumbai', 'arch', 'monument', 'apollo'],
      'labels': ['arch', 'monument', 'building', 'stone', 'gateway'],
    },
  };

  /// Initialize the ML Kit services
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      print('🔍 Initializing Monument Scanner Service...');

      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
      _objectDetector = ObjectDetector(
        options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: false,
        ),
      );

      _isInitialized = true;
      print('✅ Monument Scanner Service initialized successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to initialize Monument Scanner Service: $e');
      return Left(CacheFailure(message: 'Failed to initialize scanner: $e'));
    }
  }

  /// Scan an image for monument information
  Future<Either<Failure, MonumentInfo>> scanImage(String imagePath) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return initResult.fold((failure) => Left(failure), (_) => const Left(CacheFailure(message: 'Initialization failed')));
        }
      }

      print('🔍 Scanning image for monuments: $imagePath');

      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Run text recognition and image labeling in parallel
      final results = await Future.wait([
        _recognizeText(inputImage),
        _labelImage(inputImage),
        _detectObjects(inputImage),
      ]);

      final detectedText = results[0] as List<String>;
      final detectedLabels = results[1] as List<String>;
      final detectedObjects = results[2] as List<String>;

      print('📝 Detected text: $detectedText');
      print('🏷️ Detected labels: $detectedLabels');
      print('🎯 Detected objects: $detectedObjects');

      // Combine all detected information
      final allDetectedInfo = [...detectedText, ...detectedLabels, ...detectedObjects];

      // Try to identify the monument
      final monumentInfo = _identifyMonument(allDetectedInfo);

      if (monumentInfo != null) {
        final result = MonumentInfo(
          name: monumentInfo['name'],
          description: monumentInfo['description'],
          category: monumentInfo['category'],
          confidence: monumentInfo['confidence'],
          detectedText: detectedText,
          detectedLabels: detectedLabels,
          imagePath: imagePath,
        );

        print('✅ Monument identified: ${result.name} (${result.confidence}% confidence)');
        return Right(result);
      } else {
        // Create a generic result with detected information
        final result = MonumentInfo(
          name: 'Unknown Monument',
          description: 'Monument detected but not identified. Detected features: ${allDetectedInfo.take(5).join(', ')}',
          category: 'Unknown',
          confidence: 0.3,
          detectedText: detectedText,
          detectedLabels: detectedLabels,
          imagePath: imagePath,
        );

        print('⚠️ Monument not identified, returning generic result');
        return Right(result);
      }
    } catch (e) {
      print('❌ Error scanning image: $e');
      return Left(CacheFailure(message: 'Failed to scan image: $e'));
    }
  }

  /// Recognize text in the image
  Future<List<String>> _recognizeText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final textList = <String>[];
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.toLowerCase().trim();
          if (text.isNotEmpty && text.length > 2) {
            textList.add(text);
          }
        }
      }
      
      return textList;
    } catch (e) {
      print('❌ Text recognition error: $e');
      return [];
    }
  }

  /// Label objects in the image
  Future<List<String>> _labelImage(InputImage inputImage) async {
    try {
      final labels = await _imageLabeler.processImage(inputImage);
      return labels
          .where((label) => label.confidence > 0.5)
          .map((label) => label.label.toLowerCase())
          .toList();
    } catch (e) {
      print('❌ Image labeling error: $e');
      return [];
    }
  }

  /// Detect objects in the image
  Future<List<String>> _detectObjects(InputImage inputImage) async {
    try {
      final objects = await _objectDetector.processImage(inputImage);
      final objectLabels = <String>[];
      
      for (DetectedObject object in objects) {
        for (Label label in object.labels) {
          if (label.confidence > 0.5) {
            objectLabels.add(label.text.toLowerCase());
          }
        }
      }
      
      return objectLabels;
    } catch (e) {
      print('❌ Object detection error: $e');
      return [];
    }
  }

  /// Identify monument based on detected information
  Map<String, dynamic>? _identifyMonument(List<String> detectedInfo) {
    double bestScore = 0.0;
    Map<String, dynamic>? bestMatch;

    for (final entry in _monumentDatabase.entries) {
      final monumentData = entry.value;
      final keywords = List<String>.from(monumentData['keywords']);
      final labels = List<String>.from(monumentData['labels']);
      
      double score = 0.0;
      int matches = 0;

      // Check for keyword matches
      for (final keyword in keywords) {
        for (final detected in detectedInfo) {
          if (detected.contains(keyword) || keyword.contains(detected)) {
            score += 2.0; // Keywords have higher weight
            matches++;
          }
        }
      }

      // Check for label matches
      for (final label in labels) {
        for (final detected in detectedInfo) {
          if (detected.contains(label) || label.contains(detected)) {
            score += 1.0;
            matches++;
          }
        }
      }

      // Calculate confidence based on matches and total possible matches
      final totalPossible = keywords.length + labels.length;
      final confidence = (matches / totalPossible) * 100;

      if (score > bestScore && confidence > 20) { // Minimum 20% confidence
        bestScore = score;
        bestMatch = {
          ...monumentData,
          'confidence': confidence,
        };
      }
    }

    return bestMatch;
  }

  /// Get available cameras
  Future<Either<Failure, List<CameraDescription>>> getAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const Left(CacheFailure(message: 'No cameras available'));
      }
      return Right(cameras);
    } catch (e) {
      print('❌ Error getting cameras: $e');
      return Left(CacheFailure(message: 'Failed to get cameras: $e'));
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      await _imageLabeler.close();
      await _objectDetector.close();
      _isInitialized = false;
      print('🔍 Monument Scanner Service disposed');
    }
  }

  /// Get monument database for reference
  static Map<String, Map<String, dynamic>> get monumentDatabase => _monumentDatabase;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
