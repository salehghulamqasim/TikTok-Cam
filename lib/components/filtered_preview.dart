import 'package:flutter/material.dart';
import '../models/filter_type.dart';

class FilteredPreview extends StatelessWidget {
  final FilterType filterType;
  final Widget child;

  const FilteredPreview({
    super.key,
    required this.filterType,
    required this.child,
  });

  ColorFilter? _getColorFilter() {
    switch (filterType) {
      case FilterType.sepia:
        return const ColorFilter.matrix(<double>[
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.grayscale:
        return const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.vintage:
        return const ColorFilter.matrix(<double>[
          0.9, 0.5, 0.1, 0, 0,
          0.3, 0.8, 0.1, 0, 0,
          0.2, 0.3, 0.5, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.warm:
        return const ColorFilter.matrix(<double>[
          1.2, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 0.8, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.cool:
        return const ColorFilter.matrix(<double>[
          0.8, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 1.2, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.vivid:
        return const ColorFilter.matrix(<double>[
          1.3, 0, 0, 0, 0,
          0, 1.3, 0, 0, 0,
          0, 0, 1.3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorFilter = _getColorFilter();
    if (colorFilter == null) {
      return child;
    }
    return ColorFiltered(
      colorFilter: colorFilter,
      child: child,
    );
  }
}
