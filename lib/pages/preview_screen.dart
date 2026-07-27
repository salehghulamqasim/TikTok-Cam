import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gal/gal.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;

  const PreviewScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _controller;
  bool _isSaving = false;

  bool get _isPhoto =>
      widget.videoPath.toLowerCase().endsWith('.jpg') ||
      widget.videoPath.toLowerCase().endsWith('.jpeg');

  @override
  void initState() {
    super.initState();
    if (!_isPhoto) {
      _controller = VideoPlayerController.file(File(widget.videoPath))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _controller?.setLooping(true);
          _controller?.play();
        });
    }
  }

  Future<void> _saveMedia() async {
    setState(() => _isSaving = true);
    try {
      if (_isPhoto) {
        await Gal.putImage(widget.videoPath);
      } else {
        await Gal.putVideo(widget.videoPath);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPhoto ? 'Photo saved to gallery!' : 'Video saved to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save media: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildMediaContent() {
    if (_isPhoto) {
      return Image.file(
        File(widget.videoPath),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _controller!.value.isPlaying
                ? _controller!.pause()
                : _controller!.play();
          });
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMediaContent(),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Save button
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: _isSaving ? null : _saveMedia,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
