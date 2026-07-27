import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTapPhoto;
  final VoidCallback onLongPressStartVideo;
  final VoidCallback onLongPressEndVideo;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTapPhoto,
    required this.onLongPressStartVideo,
    required this.onLongPressEndVideo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapPhoto,
      onLongPressStart: (_) => onLongPressStartVideo(),
      onLongPressEnd: (_) => onLongPressEndVideo(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 90 : 80,
        height: isRecording ? 90 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isRecording
                ? Theme.of(context).colorScheme.primary
                : Colors.redAccent,
            borderRadius: BorderRadius.circular(isRecording ? 16 : 40),
          ),
        ),
      ),
    );
  }
}
