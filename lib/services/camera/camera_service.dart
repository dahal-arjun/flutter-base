import 'package:camera/camera.dart';
import '../../core/utils/app_logger.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;
  List<CameraDescription>? get cameras => _cameras;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  // Initialize cameras
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
      AppLogger.d('Cameras initialized', {'count': _cameras?.length ?? 0});
    } catch (e) {
      AppLogger.e('Error initializing cameras', e);
      rethrow;
    }
  }

  // Initialize camera controller
  Future<void> initializeController({
    int cameraIndex = 0,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
  }) async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initializeCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    if (cameraIndex >= _cameras!.length) {
      throw Exception('Camera index out of range');
    }

    // Dispose existing controller
    await dispose();

    _controller = CameraController(
      _cameras![cameraIndex],
      resolutionPreset,
      enableAudio: true,
    );

    await _controller!.initialize();
  }

  // Take a picture
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image;
    } catch (e) {
      AppLogger.e('Error taking picture', e);
      return null;
    }
  }

  // Start video recording
  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    if (_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
    } catch (e) {
      AppLogger.e('Error starting video recording', e);
      rethrow;
    }
  }

  // Stop video recording
  Future<XFile?> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    if (!_controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      final XFile video = await _controller!.stopVideoRecording();
      return video;
    } catch (e) {
      AppLogger.e('Error stopping video recording', e);
      return null;
    }
  }

  // Dispose camera controller
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
