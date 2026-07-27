import 'package:flutter/material.dart';

class ControlsOverlay extends StatelessWidget {
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleFlash;
  final VoidCallback onOpenFilters;
  final VoidCallback onToggleTimer;
  final bool isFlashOn;
  final int timerSeconds;

  const ControlsOverlay({
    super.key,
    required this.onFlipCamera,
    required this.onToggleFlash,
    required this.onOpenFilters,
    required this.onToggleTimer,
    this.isFlashOn = false,
    this.timerSeconds = 0,
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
          const SizedBox(height: 16),
          // Timer Button (Off / 3s / 10s)
          GestureDetector(
            onTap: onToggleTimer,
            child: Column(
              children: [
                Icon(
                  timerSeconds > 0 ? Icons.timer : Icons.timer_off,
                  size: 28,
                  color: timerSeconds > 0 ? const Color(0xFF25F4EE) : Colors.white,
                ),
                if (timerSeconds > 0)
                  Text(
                    '${timerSeconds}s',
                    style: const TextStyle(
                      color: Color(0xFF25F4EE),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
