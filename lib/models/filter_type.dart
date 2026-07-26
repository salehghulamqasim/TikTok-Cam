enum FilterType {
  none,
  sepia,
  grayscale,
  vintage,
  warm,
  cool,
  vivid,
}

extension FilterTypeExtension on FilterType {
  String get displayName {
    switch (this) {
      case FilterType.none:
        return 'Normal';
      case FilterType.sepia:
        return 'Sepia';
      case FilterType.grayscale:
        return 'B&W';
      case FilterType.vintage:
        return 'Vintage';
      case FilterType.warm:
        return 'Warm';
      case FilterType.cool:
        return 'Cool';
      case FilterType.vivid:
        return 'Vivid';
    }
  }
}
