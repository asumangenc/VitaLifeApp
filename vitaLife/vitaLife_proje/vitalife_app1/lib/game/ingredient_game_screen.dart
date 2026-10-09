import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class IngredientGameScreen extends StatefulWidget {
  const IngredientGameScreen({super.key});

  @override
  State<IngredientGameScreen> createState() => _IngredientGameScreenState();
}

class _IngredientGameScreenState extends State<IngredientGameScreen> {
  CameraController? _controller;
  Interpreter? _interpreter;

  bool _isBusy = false;
  bool _isModelLoaded = false;
  bool _streamStarted = false;

  String debugInfo = "Model bekleniyor...";
  String targetLabel = "";
  String currentPrediction = "SCANNING...";
  double currentConfidence = 0;
  int score = 0;

  final int inputSize = 224;

  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      labels = await _loadLabels();

      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_float32.tflite',
        options: InterpreterOptions()..threads = 2,
      );

      _isModelLoaded = true;
      _setRandomTarget();

      if (mounted) {
        setState(() => debugInfo = "Model hazır ✅");
      }
    } catch (e) {
      if (mounted) {
        setState(() => debugInfo = "Model yükleme hatası: $e");
      }
      return;
    }

    try {
      final cameras = await availableCameras();

      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (mounted) setState(() {});

      _startClassificationLoop();
    } catch (e) {
      if (mounted) {
        setState(() => debugInfo = "Kamera hatası: $e");
      }
    }
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/models/labels.txt');
    return raw
        .split('\n')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _setRandomTarget() {
    if (labels.isEmpty) return;

    setState(() {
      targetLabel = labels[Random().nextInt(labels.length)];
      currentPrediction = "SCANNING...";
      currentConfidence = 0;
    });
  }

  void _startClassificationLoop() {
    if (_controller == null || !_isModelLoaded || _streamStarted) return;

    _streamStarted = true;

    _controller!.startImageStream((CameraImage image) async {
      if (_isBusy || !mounted) return;

      _isBusy = true;

      try {
        final prediction = await _classifyFrame(image);

        if (!mounted || prediction == null) return;

        final detectedLabel = prediction.$1;
        final confidence = prediction.$2;

        setState(() {
          currentPrediction = detectedLabel;
          currentConfidence = confidence;
          debugInfo =
          "Algılanan: $detectedLabel - %${(confidence * 100).toStringAsFixed(1)}";
        });

        if (detectedLabel == targetLabel && confidence >= 0.60) {
          await _controller?.stopImageStream();
          _streamStarted = false;
          _showSuccessDialog();
        }
      } catch (e) {
        debugPrint("Analiz hatası: $e");
      } finally {
        _isBusy = false;
      }
    });
  }

  Future<(String, double)?> _classifyFrame(CameraImage cameraImage) async {
    final interpreter = _interpreter;
    if (interpreter == null || labels.isEmpty) return null;

    final image = _convertYUV420ToImage(cameraImage);
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (y) => List.generate(
          inputSize,
              (x) {
            final pixel = resized.getPixel(x, y);

            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(labels.length, 0.0));

    interpreter.run(input, output);

    final probabilities = output[0];

    int bestIndex = 0;
    double bestScore = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestScore) {
        bestScore = probabilities[i];
        bestIndex = i;
      }
    }

    if (bestIndex >= labels.length) return null;

    return (labels[bestIndex], bestScore);
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final imgImage = img.Image(width: width, height: height);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yp = yBytes[yIndex];
        final up = uBytes[uvIndex];
        final vp = vBytes[uvIndex];

        int r = (yp + 1.402 * (vp - 128)).round();
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
        int b = (yp + 1.772 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return imgImage;
  }

  void _showSuccessDialog() {
    setState(() => score += 10);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("TEBRİKLER! 🎉"),
        content: Text("${targetLabel.toUpperCase()} buldun!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setRandomTarget();
              _startClassificationLoop();
            },
            child: const Text("SIRADAKİ GÖREV"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Center(child: Text(debugInfo)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Puan: $score"),
        backgroundColor: Colors.indigo,
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),

          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black87,
              child: Text(
                debugInfo,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          Positioned(
            top: 85,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "GÖRÜLEN: ${currentPrediction.toUpperCase()} "
                    "%${(currentConfidence * 100).toStringAsFixed(1)}",
                style: const TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "BULMAN GEREKEN:",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    targetLabel.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_streamStarted) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }
}