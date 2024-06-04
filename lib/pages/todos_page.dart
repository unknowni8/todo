import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_provider/models/todo_model.dart';
import 'package:todo_provider/providers/providers.dart';
import 'package:todo_provider/utils/debounce.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({
    super.key,
  });

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TodoHeader(),
              const CreateTodo(),
              const SizedBox(
                height: 20.0,
              ),
              SearchAndFilterTodo(),
              const Expanded(
                child: ShowTodos(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "TODO",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          "${context.watch<ActiveTodoCountState>().activeTodoCount} items left",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.redAccent,
              ),
        ),
      ],
    );
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({super.key});

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final _createTodoController = TextEditingController();

  @override
  void dispose() {
    _createTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _createTodoController,
      decoration: const InputDecoration(
        labelText: "what to do?",
      ),
      onSubmitted: (String todoDesc) {
        if (todoDesc.trim().isNotEmpty) {
          context.read<TodoList>().addTodo(todoDesc);
          _createTodoController.clear();
        }
      },
    );
  }
}

class SearchAndFilterTodo extends StatelessWidget {
  SearchAndFilterTodo({super.key});

  final debounce = Debounce(
    milliseconds: 1000,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "search todos",
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (String? newSearchTerm) {
            if (newSearchTerm != null) {
              debounce.run(() {
                context.read<TodoSearch>().setSearchTerm(newSearchTerm);
              });
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            filterButton(
              context,
              Filter.all,
            ),
            filterButton(
              context,
              Filter.active,
            ),
            filterButton(
              context,
              Filter.completed,
            ),
          ],
        ),
      ],
    );
  }

  Widget filterButton(BuildContext context, Filter filter) {
    return TextButton(
      onPressed: () {
        context.read<TodoFilter>().changeFilter(filter);
      },
      child: Text(
        filter == Filter.all
            ? 'All'
            : filter == Filter.active
                ? 'Active'
                : 'Completed',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textColor(context, filter),
            ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    final currentFilter = context.watch<TodoFilterState>().filter;
    return currentFilter == filter ? Colors.blue : Colors.grey;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodosState>().filteredTodos;
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
      ),
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey(todos[index].id),
          background: getBackground(0),
          secondaryBackground: getBackground(1),
          onDismissed: (_) {
            context.read<TodoList>().deleteTodo(
                  todos[index].id,
                );
          },
          confirmDismiss: (_) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('Do you want to delete?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
          },
          child: TodoItem(
            item: todos[index],
          ),
        );
      },
    );
  }

  Widget getBackground(int direction) {
    return Container(
      color: Colors.redAccent,
      padding: const EdgeInsets.all(4.0),
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo item;
  const TodoItem({
    super.key,
    required this.item,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.item.completed,
        onChanged: (bool? value) {
          context.read<TodoList>().toggleTodo(
                widget.item.id,
              );
        },
      ),
      title: Text(
        widget.item.desc,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            bool error = false;
            _textController.text = widget.item.desc;
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text(
                    "Edit Todo",
                  ),
                  content: TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      errorText: error ? "value should not be empty" : null,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          error = _textController.text.isEmpty ? true : false;
                        });
                        if (!error) {
                          context.read<TodoList>().editTodo(
                                widget.item.id,
                                _textController.text,
                              );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Edit",
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
