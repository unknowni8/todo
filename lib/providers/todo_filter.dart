import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:todo_provider/models/todo_model.dart';

class TodoFilterState extends Equatable {
  final Filter filter;
  const TodoFilterState({
    required this.filter,
  });

  @override
  List<Object> get props => [filter];

  factory TodoFilterState.initial() {
    return const TodoFilterState(
      filter: Filter.all,
    );
  }

  TodoFilterState copyWith({
    Filter? filter,
  }) {
    return TodoFilterState(
      filter: filter ?? this.filter,
    );
  }

  @override
  bool get stringify => true;
}

class TodoFilter with ChangeNotifier {
  TodoFilterState _state = TodoFilterState.initial();
  TodoFilterState get state => _state;
  void changeFilter(Filter newFilter) {
    _state = _state.copyWith(filter: newFilter);
    notifyListeners();
  }
}
