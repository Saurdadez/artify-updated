import 'package:art_app/components/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({super.key, this.onTap, required this.imagePath});
  final Function()? onTap;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notifier.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            imagePath,
            height: 40,
            width: 40,
          ),
        ),
      );
    });
  }
}
