import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xLarge = 24;
  static const double xxLarge = 32;
}

abstract final class AppRadius {
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16));
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(28));
}
