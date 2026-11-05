import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';

class PmLogo extends StatelessWidget {
  const PmLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      // borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      child: Image.asset(
        AppConstants.logoAsset,
        width: width,
        fit: BoxFit.contain,
        semanticLabel: '${AppConstants.appName}, ${AppConstants.tagline}',
      ),
    );
  }
}
