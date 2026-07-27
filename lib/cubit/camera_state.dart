import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

enum CameraStatus { initial, loading, ready, recording, recorded, error }

class CameraState extends Equatable {
  final CameraStatus status;
  final int recordingDurationSeconds;
  final String? videoPath;
  final String? errorMessage;
  final bool isFrontCamera;
  final bool isFlashOn;
  final CameraController? controller;

  const CameraState({
    this.status = CameraStatus.initial,
    this.recordingDurationSeconds = 0,
    this.videoPath,
    this.errorMessage,
    this.isFrontCamera = false,
    this.isFlashOn = false,
    this.controller,
  });

  CameraState copyWith({
    CameraStatus? status,
    int? recordingDurationSeconds,
    String? videoPath,
    String? errorMessage,
    bool? isFrontCamera,
    bool? isFlashOn,
    CameraController? controller,
  }) {
    return CameraState(
      status: status ?? this.status,
      recordingDurationSeconds:
          recordingDurationSeconds ?? this.recordingDurationSeconds,
      videoPath: videoPath ?? this.videoPath,
      errorMessage: errorMessage ?? this.errorMessage,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      controller: controller ?? this.controller,
    );
  }

  // controller is intentionally excluded from props:
  // its object identity isn't reliably comparable and
  // doesn't need to trigger rebuilds by itself.
  @override
  List<Object?> get props => [
    status,
    recordingDurationSeconds,
    videoPath,
    errorMessage,
    isFrontCamera,
    isFlashOn,
  ];
}
