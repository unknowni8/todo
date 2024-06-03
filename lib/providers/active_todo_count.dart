import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_provider/providers/todo_list.dart';

import '../models/todo_model.dart';

class ActiveTodoCountState extends Equatable {
  final int activeTodoCount;
  const ActiveTodoCountState({
    required this.activeTodoCount,
  });

  factory ActiveTodoCountState.initial() {
    return const ActiveTodoCountState(activeTodoCount: 0);
  }

  @override
  List<Object> get props => [activeTodoCount];

  @override
  bool get stringify => true;

  ActiveTodoCountState copyWith({
    int? activeTodoCount,
  }) {
    return ActiveTodoCountState(
      activeTodoCount: activeTodoCount ?? this.activeTodoCount,
    );
  }
}

class ActiveTodoCount with ChangeNotifier {
  // ActiveTodoCountState _state = ActiveTodoCountState.initial();
  late ActiveTodoCountState _state;
  int initialActiveTodoCount;
  ActiveTodoCount({required this.initialActiveTodoCount,}){
    _state = ActiveTodoCountState(activeTodoCount: initialActiveTodoCount);
  }
  ActiveTodoCountState get state => _state;

  void update(TodoList todoList) {
    final newActiveTodoCount = todoList.state.todos
        .where((Todo todo) => !todo.completed)
        .toList()
        .length;
    _state = _state.copyWith(
      activeTodoCount: newActiveTodoCount,
    );
    notifyListeners();
  }
}