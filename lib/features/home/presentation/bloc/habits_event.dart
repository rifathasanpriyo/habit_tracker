part of 'habits_bloc.dart';

@immutable
sealed class HabitsEvent {}


class FeatchHabitsEvent extends HabitsEvent {}

class AddHabitsEvent extends HabitsEvent { 
  final String? habitName;
  AddHabitsEvent(this.habitName);
}