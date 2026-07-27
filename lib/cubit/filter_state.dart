import 'package:equatable/equatable.dart';
import '../models/filter_type.dart';

class FilterState extends Equatable {
  final FilterType selectedFilter;

  const FilterState({
    this.selectedFilter = FilterType.none,
  });

  FilterState copyWith({
    FilterType? selectedFilter,
  }) {
    return FilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [selectedFilter];
}
