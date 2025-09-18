import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

class ProfileCropper extends StatefulWidget {
  final Uint8List imageBytes;
  const ProfileCropper({super.key, required this.imageBytes});

  @override
  State<ProfileCropper> createState() => _ProfileCropperState();
}

class _ProfileCropperState extends State<ProfileCropper> {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Crop(
            image: widget.imageBytes,
            controller: _controller,
            withCircleUi: true, // ✅ circle crop UI
            onCropped: (croppedData) {
              Navigator.pop(context, croppedData); // return cropped bytes
            },
          ),
        ),
        ElevatedButton(
          onPressed: () => _controller.crop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
