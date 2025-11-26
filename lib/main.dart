

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexTick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Keep splash for 2 seconds then navigate to HomePage
    Timer(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple logo circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.checklist_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'NexTick',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Organize your day',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  String id;
  String title;
  DateTime? dueDate;
  bool isComplete;
  bool isImportant;

  TodoItem({
    required this.id,
    required this.title,
    this.dueDate,
    this.isComplete = false,
    this.isImportant = false,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'] as String,
    title: json['title'] as String,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    isComplete: json['isComplete'] ?? false,
    isImportant: json['isImportant'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate?.toIso8601String(),
    'isComplete': isComplete,
    'isImportant': isImportant,
  };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TodoItem> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('todos');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _todos.clear();
        for (final e in list) {
          _todos.add(TodoItem.fromJson(Map<String, dynamic>.from(e)));
        }
      } catch (e) {
        // ignore and start fresh
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString('todos', raw);
  }

  int get upcomingCount => _todos.where((t) => !t.isComplete).length;
  int get completedCount => _todos.where((t) => t.isComplete).length;
  int get importantCount => _todos.where((t) => t.isImportant).length;

  void _addTodo(TodoItem t) {
    setState(() {
      _todos.add(t);
    });
    _saveTodos();
  }

  void _updateTodo(TodoItem t) {
    setState(() {});
    _saveTodos();
  }

  void _removeTodo(TodoItem t) {
    setState(() {
      _todos.removeWhere((e) => e.id == t.id);
    });
    _saveTodos();
  }

  // helper actions passed to filtered page
  void _toggleComplete(TodoItem t) {
    setState(() => t.isComplete = !t.isComplete);
    _saveTodos();
  }

  void _toggleImportant(TodoItem t) {
    setState(() => t.isImportant = !t.isImportant);
    _saveTodos();
  }

  Future<void> _showAddDialog() async {
    final titleCtrl = TextEditingController();
    DateTime? due;
    bool important = false;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: StatefulBuilder(
          builder: (context, setInner) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        due == null
                            ? 'No due date'
                            : 'Due: ${due?.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setInner(() => due = picked);
                      },
                      child: const Text('Pick date'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: important,
                      onChanged: (v) => setInner(() => important = v ?? false),
                    ),
                    const Text('Mark as important'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = titleCtrl.text.trim();
              if (text.isEmpty) return;
              final item = TodoItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: text,
                dueDate: due,
                isImportant: important,
              );
              _addTodo(item);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCountsCard(
    String label,
    int count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.12),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilteredPage(String title, List<TodoItem> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilteredTodosPage(
          title: title,
          items: items,
          onToggleComplete: _toggleComplete,
          onToggleImportant: _toggleImportant,
          onEdit: (t) async {
            await _showEditDialog(t);
          },
          onDelete: _removeTodo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            onPressed: _todos.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Clear all todos?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      setState(() => _todos.clear());
                      _saveTodos();
                    }
                  },
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCountsCard(
                        'Upcoming',
                        upcomingCount,
                        Icons.schedule,
                        Colors.indigo,
                        () {
                          _openFilteredPage(
                            'Upcoming',
                            _todos.where((t) => !t.isComplete).toList(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCountsCard(
                        'Completed',
                        completedCount,
                        Icons.check_circle,
                        const Color.fromARGB(255, 45, 212, 51),
                        () {
                          _openFilteredPage(
                            'Completed',
                            _todos.where((t) => t.isComplete).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCountsCard(
                        'Important',
                        importantCount,
                        Icons.star,
                        const Color.fromARGB(255, 243, 187, 20),
                        () {
                          _openFilteredPage(
                            'Important',
                            _todos.where((t) => t.isImportant).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "All Todo list",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _todos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No todos yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Add tasks',
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (_, __) =>
                                const Divider(height: 0),
                            itemCount: _todos.length,
                            itemBuilder: (context, idx) {
                              final t = _todos[idx];
                              return Dismissible(
                                key: ValueKey(t.id),
                                background: Container(
                                  color: Colors.redAccent,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: const Color.fromARGB(255, 255, 147, 7),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.archive,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (dir) => _removeTodo(t),
                                child: ListTile(
                                  leading: IconButton(
                                    onPressed: () {
                                      _toggleComplete(t);
                                    },
                                    icon: Icon(
                                      t.isComplete
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                    ),
                                  ),
                                  title: Text(
                                    t.title,
                                    style: TextStyle(
                                      decoration: t.isComplete
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: t.dueDate != null
                                      ? Text(
                                          'Due ${t.dueDate!.toLocal().toString().split(' ')[0]}',
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _toggleImportant(t);
                                        },
                                        icon: Icon(
                                          t.isImportant
                                              ? Icons.star
                                              : Icons.star_border,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) async {
                                          if (v == 'edit') {
                                            await _showEditDialog(t);
                                          } else if (v == 'delete') {
                                            _removeTodo(t);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text('Add Todo'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEditDialog(TodoItem t) async {
    final titleCtrl = TextEditingController(text: t.title);
    DateTime? due = t.dueDate;
    bool important = t.isImportant;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: StatefulBuilder(
          builder: (context, setInner) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        due == null
                            ? 'No due date'
                            : 'Due: ${due!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: due ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setInner(() => due = picked);
                      },
                      child: const Text('Pick date'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: important,
                      onChanged: (v) => setInner(() => important = v ?? false),
                    ),
                    const Text('Important'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = titleCtrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                t.title = text;
                t.dueDate = due;
                t.isImportant = important;
              });
              _saveTodos();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class FilteredTodosPage extends StatelessWidget {
  final String title;
  final List<TodoItem> items;
  final void Function(TodoItem) onToggleComplete;
  final void Function(TodoItem) onToggleImportant;
  final Future<void> Function(TodoItem) onEdit;
  final void Function(TodoItem) onDelete;

  const FilteredTodosPage({
    super.key,
    required this.title,
    required this.items,
    required this.onToggleComplete,
    required this.onToggleImportant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox, size: 72, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'No $title tasks',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final t = items[idx];
                return Dismissible(
                  key: ValueKey(t.id),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.orangeAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.archive, color: Colors.white),
                  ),
                  onDismissed: (dir) {
                    onDelete(t);
                  },
                  child: ListTile(
                    leading: IconButton(
                      onPressed: () => onToggleComplete(t),
                      icon: Icon(
                        t.isComplete
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: t.dueDate != null
                        ? Text(
                            'Due ${t.dueDate!.toLocal().toString().split(' ')[0]}',
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => onToggleImportant(t),
                          icon: Icon(
                            t.isImportant ? Icons.star : Icons.star_border,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') await onEdit(t);
                            if (v == 'delete') onDelete(t);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
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
