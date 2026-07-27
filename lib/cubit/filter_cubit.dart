import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/filter_type.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  void selectFilter(FilterType filter) {
    emit(state.copyWith(selectedFilter: filter));
  }
}
