import 'dart:ui';

import 'package:art_app/components/image_expanded.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<ImageProvider> imgProviders;
  final int currentIndex;

  const ImageCarousel({
    super.key,
    required this.imgProviders,
    required this.currentIndex,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with AutomaticKeepAliveClientMixin<ImageCarousel> {
  @override
  bool get wantKeepAlive => true;
  String? getImageUrl(ImageProvider imageProvider) {
    String imageProviderString = imageProvider.toString();

    // Parsing the URL from the string representation of CachedNetworkImageProvider
    RegExp regExp = RegExp(r'(http|https):\/\/[^ "]+');
    Iterable<RegExpMatch> matches = regExp.allMatches(imageProviderString);

    if (matches.isNotEmpty) {
      return matches.first.group(0); // Extracting the URL
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageExpanded(
              imgProviders: widget.imgProviders[widget.currentIndex],
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: widget.imgProviders[widget.currentIndex],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl:
                  getImageUrl(widget.imgProviders[widget.currentIndex]) ?? '',
              fit: BoxFit.contain,
            ),
          ),
/*
          Container(
            height: double.infinity,
            width: double.infinity,
            child: CustomFadeInImage(
              imageUrl:
                  getImageUrl(widget.imgProviders[widget.currentIndex]) ?? '',
              fit: BoxFit.contain,
            ),
          ),
          */
        ],
      ),
    );
  }
}
