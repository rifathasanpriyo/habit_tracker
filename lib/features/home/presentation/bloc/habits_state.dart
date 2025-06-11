part of 'habits_bloc.dart';

@immutable
sealed class HabitsState {}

final class HabitsInitial extends HabitsState {}

final class HabitsLoading extends HabitsState {}
final class HabitsSuccess extends HabitsState {
  final List<String> habits;

  HabitsSuccess(this.habits);
}
final class HabitsError extends HabitsState {
  final String message;

  HabitsError(this.message);
}