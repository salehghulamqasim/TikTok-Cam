import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';
import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';
import '../components/controls_overlay.dart';
import '../components/filter_selector.dart';
import '../components/filtered_preview.dart';
import '../components/record_button.dart';
import '../components/recording_timer.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _showFilters = false;

  // Zoom: we track the zoom at the start of each pinch separately.
  // This prevents the "jump" bug caused by multiplying the running zoom by a new scale factor mid-gesture.
  double _baseZoom = 1.0;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  // Tap-to-focus ring: stores the screen position of the last tap, clears after a short delay.
  Offset? _focusPoint;
  Timer? _focusTimer;

  // Countdown timer setting (Off / 3s / 10s) — how long to wait before taking a photo.
  int _countdownSeconds = 0;

  // Active countdown: counts down from _countdownSeconds to 0, then takes the photo.
  int _activeCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    context.read<CameraCubit>().initialize();
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Called when the pinch gesture starts — saves the zoom level we were at BEFORE the new pinch.
  // Without this, each new pinch starts from the default scale factor (1.0), causing a zoom jump.
  Future<void> _onScaleStart(ScaleStartDetails details, CameraController controller) async {
    _baseZoom = _currentZoom;
    _minZoom = await controller.getMinZoomLevel();
    _maxZoom = await controller.getMaxZoomLevel();
  }

  // Called every frame during pinch — multiplies the base (start) zoom by the gesture's scale factor.
  void _onScaleUpdate(ScaleUpdateDetails details, CameraController controller) {
    if (details.pointerCount < 2) return; // ignore single-finger swipes
    final newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
    _currentZoom = newZoom;
    controller.setZoomLevel(newZoom);
  }

  // Called when user lifts fingers — nothing to do, _currentZoom is already correct.
  void _onScaleEnd(ScaleEndDetails _) {}

  // Called on tap — sets focus & exposure point and shows a visual ring at that position.
  void _onTapFocus(TapDownDetails details, CameraController controller) {
    final size = MediaQuery.of(context).size;

    // Camera expects a normalized offset (0.0 to 1.0), not raw pixels.
    final normalized = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    controller.setFocusPoint(normalized);
    controller.setExposurePoint(normalized); // also move exposure to where you tapped

    // Show focus ring at tap position, then remove it after 1.5 seconds.
    _focusTimer?.cancel();
    setState(() => _focusPoint = details.localPosition);
    _focusTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  void _cycleCountdown() {
    setState(() {
      // Cycles: Off → 3s → 10s → Off
      if (_countdownSeconds == 0) {
        _countdownSeconds = 3;
      } else if (_countdownSeconds == 3) {
        _countdownSeconds = 10;
      } else {
        _countdownSeconds = 0;
      }
    });
  }

  // If a timer is set, count down then take photo. Otherwise take photo immediately.
  void _handleTakePhoto() {
    if (_countdownSeconds == 0) {
      context.read<CameraCubit>().takePhoto();
      return;
    }

    // Cancel any previous countdown that might still be running.
    _countdownTimer?.cancel();
    setState(() => _activeCountdown = _countdownSeconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeCountdown <= 1) {
        timer.cancel();
        setState(() => _activeCountdown = 0);
        context.read<CameraCubit>().takePhoto();
      } else {
        setState(() => _activeCountdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraCubit, CameraState>(
      listener: (context, state) {
        if (state.status == CameraStatus.recorded && state.videoPath != null) {
          final cubit = context.read<CameraCubit>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PreviewScreen(videoPath: state.videoPath!),
            ),
          ).then((_) {
            if (!mounted) return;
            cubit.reset();
          });
        }
      },
      builder: (context, cameraState) {
        if (cameraState.status == CameraStatus.initial ||
            cameraState.status == CameraStatus.loading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (cameraState.status == CameraStatus.error) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFE2C55), Color(0xFF25F4EE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.videocam_off, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Camera Unavailable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Run on a real Android or iOS device\nto use the camera.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final controller = cameraState.controller;

        return BlocBuilder<FilterCubit, FilterState>(
          builder: (context, filterState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // Live camera preview with color filter applied
                  if (controller != null && controller.value.isInitialized)
                    FilteredPreview(
                      filterType: filterState.selectedFilter,
                      child: GestureDetector(
                        onScaleStart: (d) => _onScaleStart(d, controller),
                        onScaleUpdate: (d) => _onScaleUpdate(d, controller),
                        onScaleEnd: (d) => _onScaleEnd(d),
                        onTapDown: (d) => _onTapFocus(d, controller),
                        child: Builder(
                          builder: (context) {
                            final size = MediaQuery.of(context).size;
                            // Scale the preview to fill the screen without stretching
                            var scale = size.aspectRatio * controller.value.aspectRatio;
                            if (scale < 1) scale = 1 / scale;

                            return Transform.scale(
                              scale: scale,
                              child: Center(
                                child: CameraPreview(controller),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Focus ring: appears at the tap position for 1.5 seconds then fades
                  if (_focusPoint != null)
                    Positioned(
                      left: _focusPoint!.dx - 35,
                      top: _focusPoint!.dy - 35,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                  // Top Header Bar (hidden during recording)
                  if (cameraState.status != CameraStatus.recording)
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ),

                  // Recording timer HUD
                  if (cameraState.status == CameraStatus.recording)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: RecordingTimer(
                          durationSeconds: cameraState.recordingDurationSeconds,
                        ),
                      ),
                    ),

                  // Countdown number shown in the center of the screen
                  if (_activeCountdown > 0)
                    Center(
                      child: Text(
                        '$_activeCountdown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 20, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),

                  // Side controls (hidden during recording)
                  if (cameraState.status != CameraStatus.recording)
                    ControlsOverlay(
                      isFlashOn: cameraState.isFlashOn,
                      timerSeconds: _countdownSeconds,
                      onFlipCamera: () => context.read<CameraCubit>().toggleCamera(),
                      onToggleFlash: () => context.read<CameraCubit>().toggleFlash(),
                      onOpenFilters: () => setState(() => _showFilters = !_showFilters),
                      onToggleTimer: _cycleCountdown,
                    ),

                  // Bottom: filter picker + record button
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_showFilters && cameraState.status != CameraStatus.recording) ...[
                          FilterSelector(
                            selectedFilter: filterState.selectedFilter,
                            onFilterSelected: (filter) {
                              context.read<FilterCubit>().selectFilter(filter);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                        RecordButton(
                          isRecording: cameraState.status == CameraStatus.recording,
                          onTapPhoto: _handleTakePhoto, // uses countdown if set
                          onLongPressStartVideo: () => context.read<CameraCubit>().startRecording(),
                          onLongPressEndVideo: () => context.read<CameraCubit>().stopRecording(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
