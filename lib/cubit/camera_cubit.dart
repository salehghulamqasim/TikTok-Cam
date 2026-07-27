import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/camera_service.dart';
import '../utils/permission_helper.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraService _cameraService;
  Timer? _timer;

  CameraCubit({CameraService? cameraService})
    : _cameraService = cameraService ?? CameraService(),
      super(const CameraState());

  Future<void> initialize() async {
    emit(state.copyWith(status: CameraStatus.loading));
    try {
      final hasPermission =
          await PermissionHelper.requestCameraAndMicPermissions();
      if (!hasPermission) {
        emit(state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Camera & microphone permissions are required.',
        ));
        return;
      }
      await _cameraService.initialize();
      emit(state.copyWith(
        status: CameraStatus.ready,
        controller: _cameraService.controller,
      ));
    } catch (e) {
      // On web or unsupported platforms the camera plugin throws immediately.
      // We surface a clear message instead of hanging on loading forever.
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Camera unavailable on this platform.\n\n$e',
      ));
    }
  }

  Future<void> startRecording() async {
    if (state.status != CameraStatus.ready) return;
    await _cameraService.startRecording();
    emit(
      state.copyWith(
        status: CameraStatus.recording,
        recordingDurationSeconds: 0,
      ),
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(
        state.copyWith(
          recordingDurationSeconds: state.recordingDurationSeconds + 1,
        ),
      );
    });
  }

  //this function is used for stopping recording
  Future<void> stopRecording() async {
    _timer?.cancel();
    final path = await _cameraService.stopRecording();
    emit(state.copyWith(status: CameraStatus.recorded, videoPath: path));
  }

  /// Takes a photo and updates state to recorded so the preview screen opens.
  Future<void> takePhoto() async {
    if (state.status != CameraStatus.ready) return;
    try {
      final path = await _cameraService.takePhoto();
      if (path != null) {
        emit(state.copyWith(
          status: CameraStatus.recorded,
          videoPath: path,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to take photo: $e',
      ));
    }
  }

  Future<void> toggleCamera() async {
    final newIsFrontCamera = !state.isFrontCamera;

    // 1. Tell UI we are loading so it removes the old camera preview cleanly
    emit(
      state.copyWith(
        status: CameraStatus.loading,
        isFrontCamera: newIsFrontCamera,
        controller: null,
      ),
    );

    try {
      // 2. Switch camera hardware
      await _cameraService.switchCamera(newIsFrontCamera);

      // 3. Emit ready status with the new controller
      emit(
        state.copyWith(
          status: CameraStatus.ready,
          controller: _cameraService.controller,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to switch camera: $e',
        ),
      );
    }
  }

  //this function is used for changing state of flash light
  //if user toggles flash light on then it sends copyWith to inform the program to change state of flash
  Future<void> toggleFlash() async {
    final newIsFlashOn = !state.isFlashOn;
    await _cameraService.toggleFlash(newIsFlashOn);
    emit(state.copyWith(isFlashOn: newIsFlashOn));
  }

  //this function is used for resetting the camera
  void reset() {
    _timer?.cancel();
    emit(
      state.copyWith(
        status: CameraStatus.ready,
        recordingDurationSeconds: 0,
        videoPath: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _cameraService.dispose();
    return super.close();
  }
}
