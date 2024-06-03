import 'package:flutter/material.dart';
import 'package:todo_provider/pages/todos_page.dart';
import 'package:provider/provider.dart';
import 'package:todo_provider/providers/providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoList>(
          create: (_) => TodoList(),
        ),
        ChangeNotifierProvider<TodoFilter>(
          create: (_) => TodoFilter(),
        ),
        ChangeNotifierProvider<TodoSearch>(
          create: (_) => TodoSearch(),
        ),
        ChangeNotifierProxyProvider<TodoList, ActiveTodoCount>(
            create: (context) => ActiveTodoCount(
              initialActiveTodoCount: context.read<TodoList>().state.todos.length,
            ),
            update: (
              BuildContext context,
              TodoList todoList,
              ActiveTodoCount? activeTodoCount,
            ) {
              return activeTodoCount!..update(todoList);
            },),
        ChangeNotifierProxyProvider3<TodoFilter, TodoSearch, TodoList, FilteredTodos>(
          create: (context) => FilteredTodos(
            initialFilteredTodos: context.read<TodoList>().state.todos,
          ),
          update: (context, todoFilter, todoSearch, todoList, previous) {
            return previous!..update(todoFilter, todoSearch, todoList);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.cyan,
          textTheme: const TextTheme(),
        ),
        home: const TodosPage(),
      ),
    );
  }
}
