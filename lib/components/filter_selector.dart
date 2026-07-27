import 'package:flutter/material.dart';
import '../models/filter_type.dart';

class FilterSelector extends StatelessWidget {
  final FilterType selectedFilter;
  final ValueChanged<FilterType> onFilterSelected;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FilterType.values.length,
        itemBuilder: (context, index) {
          final filter = FilterType.values[index];
          final isSelected = filter == selectedFilter;
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white30,
                        width: isSelected ? 3 : 1,
                      ),
                      color: Colors.grey.shade900,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 24,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    filter.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
