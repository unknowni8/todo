import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_provider/providers/todo_filter.dart';
import 'package:todo_provider/providers/todo_list.dart';
import 'package:todo_provider/providers/todo_search.dart';

import '../models/todo_model.dart';

class FilteredTodosState extends Equatable {
  final List<Todo> filteredTodos;
  const FilteredTodosState({
    required this.filteredTodos,
  });

  factory FilteredTodosState.initial() {
    return const FilteredTodosState(filteredTodos: []);
  }

  @override
  List<Object> get props => [filteredTodos];

  @override
  bool get stringify => true;

  FilteredTodosState copyWith({
    List<Todo>? filteredTodos,
  }) {
    return FilteredTodosState(
      filteredTodos: filteredTodos ?? this.filteredTodos,
    );
  }
}

class FilteredTodos with ChangeNotifier {
  // FilteredTodosState _state = FilteredTodosState.initial();
  late FilteredTodosState _state;
  final List<Todo> initialFilteredTodos;
  FilteredTodos({required this.initialFilteredTodos,}){
    _state = FilteredTodosState(filteredTodos: initialFilteredTodos);
  }
  FilteredTodosState get state => _state;

  void update(
    TodoFilter todoFilter,
    TodoSearch todoSearch,
    TodoList todoList,
  ) {
    List<Todo> filteredTodos;
    switch (todoFilter.state.filter) {
      case Filter.active:
        filteredTodos =
            todoList.state.todos.where((Todo todo) => !todo.completed).toList();
        break;
      case Filter.completed:
        filteredTodos =
            todoList.state.todos.where((Todo todo) => todo.completed).toList();
        break;
      case Filter.all:
      default:
        filteredTodos = todoList.state.todos;
        break;
    }

    if (todoSearch.state.searchTerm.isNotEmpty) {
      filteredTodos = filteredTodos
          .where(
            (Todo todo) =>
                todo.desc.toLowerCase().contains(todoSearch.state.searchTerm),
          )
          .toList();
    }
    _state = _state.copyWith(filteredTodos: filteredTodos);
    notifyListeners();
  }
}
