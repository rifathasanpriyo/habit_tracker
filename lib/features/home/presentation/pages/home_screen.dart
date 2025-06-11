import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:havit_tracker/core/constants/app_sizes.dart';
import 'package:havit_tracker/features/home/presentation/bloc/habits_bloc.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State to manage the checked status of checkboxes

  final List<ValueNotifier<bool>> isCheckedList = List.generate(
    10,
    (_) => ValueNotifier<bool>(false),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: widget.themeNotifier,
          builder: (context, mode, _) {
            final isDarkMode = mode == ThemeMode.dark;
            return Center(
              child: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  widget.themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {

          if(state is HabitsLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          else if(state is HabitsSuccess) {
            return ListView.builder(
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(AppSizes.bodyPadding - 10),
                  padding: EdgeInsets.all(AppSizes.insidePadding + 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.habits[index],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isCheckedList[index],
                        builder: (context, value, child) {
                          return Checkbox(
                            value: value,
                            onChanged: (bool? newValue) {
                              isCheckedList[index].value = newValue ?? false;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
            
          }
          else if(state is HabitsError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          else {
            return const Center(
              child: Text('No Habits Found'),
            );
          }
       
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showHabitDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    
    );
  }
}

void showHabitDialog(BuildContext context) {
  TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Habit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Habit name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<HabitsBloc>().add(AddHabitsEvent(name));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
