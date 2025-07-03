import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:securecapture/core/widgets/custom_app_bar.dart';

class ImageViewScreen extends StatelessWidget {
  const ImageViewScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Image'),
      body: Image.memory(imageBytes),
    );
  }
}
