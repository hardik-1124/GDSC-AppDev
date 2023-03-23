import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  String title;
  String timestamp;

  Todo({
    required this.title,
    this.timestamp = "",
  });
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> todos = [];
  TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // load saved todos from local storage
    loadTodos();
  }

  void loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todos = (prefs.getStringList('todos') ?? []).map((e) {
        List<String> todo = e.split(";");
        return Todo(
          title: todo[0],
          timestamp: todo[1],
        );
      }).toList();
    });
  }

  void saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoStrings = todos.map((e) => "${e.title};${e.timestamp}").toList();
    prefs.setStringList('todos', todoStrings);
  }

  void addTodo() {
    setState(() {
      todos.add(Todo(
        title: todoController.text,
        timestamp: DateTime.now().toString(),
      ));
      todoController.clear();
    });
    saveTodos();
  }

  void editTodo(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = todos[index].title;
        return AlertDialog(
          title: Text("Edit Todo"),
          content: TextField(
            controller: TextEditingController(text: title),
            onChanged: (value) => title = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todos[index].title = title;
                });
                saveTodos();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: Column(
        children: [
          TextField(
            controller: todoController,
            decoration: InputDecoration(
              hintText: "Enter a todo",
              contentPadding: EdgeInsets.all(16),
            ),
            onSubmitted: (_) => addTodo(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                Todo todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.timestamp),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editTodo(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTodo(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: TodoApp()));

