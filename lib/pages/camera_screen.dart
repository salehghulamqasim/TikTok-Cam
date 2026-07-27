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
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    context.read<CameraCubit>().initialize();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, CameraController controller) {
    double scale = _currentZoom * details.scale;
    if (scale < _minZoom) scale = _minZoom;
    if (scale > _maxZoom) scale = _maxZoom;
    controller.setZoomLevel(scale);
  }

  void _handleScaleEnd(ScaleEndDetails details, CameraController controller) {
    // Persist the final zoom level for the next pinch gesture
    _currentZoom = _currentZoom * details.velocity.pixelsPerSecond.distance.clamp(0.8, 1.2);
    _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
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
            // When returning from preview, reset state to ready.
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
                  // Camera View Placeholder with active filter
                  if (controller != null && controller.value.isInitialized)
                    FilteredPreview(
                      filterType: filterState.selectedFilter,
                      child: GestureDetector(
                        onScaleStart: (details) async {
                          // Note: controller doesn't have getZoomLevel(), so we use our tracked _currentZoom
                          _minZoom = await controller.getMinZoomLevel();
                          _maxZoom = await controller.getMaxZoomLevel();
                        },
                        onScaleUpdate: (details) => _handleScaleUpdate(details, controller),
                        onScaleEnd: (details) => _handleScaleEnd(details, controller),
                        onTapDown: (details) {
                          // Tap to focus
                          final offset = Offset(
                            details.localPosition.dx / MediaQuery.of(context).size.width,
                            details.localPosition.dy / MediaQuery.of(context).size.height,
                          );
                          controller.setFocusPoint(offset);
                        },
                        child: Builder(
                          builder: (context) {
                            final size = MediaQuery.of(context).size;
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

                  // Top Header Bar
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

                  // Timer overlay when recording
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

                  // Controls Overlay (Flip camera, Flash, Filters)
                  if (cameraState.status != CameraStatus.recording)
                    ControlsOverlay(
                      isFlashOn: cameraState.isFlashOn,
                      onFlipCamera: () => context.read<CameraCubit>().toggleCamera(),
                      onToggleFlash: () => context.read<CameraCubit>().toggleFlash(),
                      onOpenFilters: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),

                  // Bottom Controls (Record button and Filter selector)
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
                          onTapPhoto: () => context.read<CameraCubit>().takePhoto(),
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
