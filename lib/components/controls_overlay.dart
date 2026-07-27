import 'package:flutter/material.dart';

class ControlsOverlay extends StatelessWidget {
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleFlash;
  final VoidCallback onOpenFilters;
  final bool isFlashOn;

  const ControlsOverlay({
    super.key,
    required this.onFlipCamera,
    required this.onToggleFlash,
    required this.onOpenFilters,
    this.isFlashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, size: 28),
            onPressed: onFlipCamera,
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              size: 28,
              color: isFlashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: onToggleFlash,
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.filter_vintage, size: 28),
            onPressed: onOpenFilters,
          ),
        ],
      ),
    );
  }
}
