import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageExpanded extends StatelessWidget {
  const ImageExpanded({
    super.key,
    required this.imgProviders,
  });

  final ImageProvider imgProviders;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: imgProviders,
        backgroundDecoration:
            const BoxDecoration(color: Color.fromARGB(191, 0, 0, 0)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
      ),
    );
  }
}
