import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

part 'habits_event.dart';
part 'habits_state.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
    final FlutterSecureStorage storage;

  HabitsBloc(this.storage) : super(HabitsInitial()) {
    on<FeatchHabitsEvent>(_onLoadHabits);
    on<AddHabitsEvent>(_onAddHabit);
  }

  Future<void> _onLoadHabits(FeatchHabitsEvent event, Emitter<HabitsState> emit) async {
    emit(HabitsLoading());
    final data = await storage.read(key: 'habit_list');
    final habits = data?.split('|') ?? [];
    emit(HabitsSuccess(habits));
  }

  Future<void> _onAddHabit(AddHabitsEvent event, Emitter<HabitsState> emit) async {
    final data = await storage.read(key: 'habit_list');
    final habits = data?.split('|') ?? [];
    habits.add(event.habitName ?? '');
    await storage.write(key: 'habit_list', value: habits.join('|'));
    emit(HabitsSuccess(habits));
  }
}