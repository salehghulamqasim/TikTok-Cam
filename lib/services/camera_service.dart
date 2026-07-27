import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller!.initialize();
    _isInitialized = true;
  }

  Future<void> startRecording() async {
    if (controller == null || !controller!.value.isInitialized) return;
    if (controller!.value.isRecordingVideo) return;

    await controller!.startVideoRecording();
    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    if (controller == null || !controller!.value.isRecordingVideo) return null;

    final XFile videoFile = await controller!.stopVideoRecording();
    _isRecording = false;
    return videoFile.path;
  }

  /// Captures a still photo and returns its local file path.
  Future<String?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    final XFile photo = await controller!.takePicture();
    return photo.path;
  }

  Future<void> switchCamera(bool isFrontCamera) async {
    if (_cameras.isEmpty) return;

    // 1. Dispose old controller FIRST to release phone camera hardware
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }

    // 2. Find target camera (front or back)
    CameraDescription newCamera = _cameras.firstWhere(
      (camera) => isFrontCamera
          ? camera.lensDirection == CameraLensDirection.front
          : camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    // 3. Create and initialize the new camera controller
    controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller!.initialize();
  }

  Future<void> toggleFlash(bool isFlashOn) async {
    if (controller == null || !controller!.value.isInitialized) return;
    await controller!.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> dispose() async {
    await controller?.dispose();
    _isInitialized = false;
    _isRecording = false;
  }
}
