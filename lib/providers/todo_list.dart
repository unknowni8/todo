import 'package:equatable/equatable.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/todo_model.dart';

class TodoListState extends Equatable {
  final List<Todo> todos;

  const TodoListState({
    required this.todos,
  });

  factory TodoListState.initial() {
    return const TodoListState(
      todos: [],
    );
  }

  @override
  List<Object> get props => [todos];

  @override
  bool get stringify => true;

  TodoListState copyWith({
    List<Todo>? todos,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
    );
  }
}

class TodoList extends StateNotifier<TodoListState> {
  TodoList() : super(TodoListState.initial());

  void addTodo(String desc) {
    final newTodo = Todo(desc: desc);
    final newTodos = [...state.todos, newTodo];
    state = state.copyWith(todos: newTodos);
  }

  void editTodo(String id, String todoDesc) {
    final newTodos = state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(
          id: id,
          desc: todoDesc,
          completed: todo.completed,
        );
      }
      return todo;
    }).toList();
    state = state.copyWith(
      todos: newTodos,
    );
  }

  void toggleTodo(String id) {
    final newTodos = state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(
          id: id,
          desc: todo.desc,
          completed: !todo.completed,
        );
      }
      return todo;
    }).toList();
    state = state.copyWith(
      todos: newTodos,
    );
  }

  void deleteTodo(String id) {
    final newTodos = state.todos
        .where(
          (Todo todo) => todo.id != id,
        )
        .toList();
    state = state.copyWith(
      todos: newTodos,
    );
  }
}
