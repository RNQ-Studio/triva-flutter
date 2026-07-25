import 'package:flutter/material.dart';

class TrivaLogo extends StatelessWidget {
  const TrivaLogo({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      package: 'features_shared',
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'TRIVA',
    );
  }
}
