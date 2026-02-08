import 'package:flutter/material.dart';

/// A state which represents car manufacturer.
enum Brand {
  daihatsu,
  honda,
  mazda,
  mitsubishi,
  nissan,
  subaru,
  suzuki,
  toyota,
}

/// Convenient helper.
extension BrandX on Brand {
  /// Returns the company name.
  String get displayName => name.toUpperCase();

  /// Returns the signature brand color for each Japanese automotive manufacturer.
  Color get accentColor {
    switch (this) {
      case Brand.daihatsu:
        return Colors.red;
      case Brand.honda:
        return Colors.redAccent;
      case Brand.mazda:
        return Colors.red[900]!;
      case Brand.mitsubishi:
        return Colors.redAccent[700]!;
      case Brand.nissan:
        return Colors.grey[600]!;
      case Brand.subaru:
        return Colors.blue[800]!;
      case Brand.suzuki:
        return Colors.blueAccent[700]!;
      case Brand.toyota:
        return Colors.red;
    }
  }
}
