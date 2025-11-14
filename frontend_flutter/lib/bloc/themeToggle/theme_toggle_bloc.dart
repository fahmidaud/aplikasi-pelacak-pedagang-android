import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_toggle_event.dart';
part 'theme_toggle_state.dart';

class ThemeToggleBloc extends Bloc<ThemeToggleEvent, ThemeToggleState> {
  ThemeToggleBloc() : super(ThemeToggleStateIsDark()) {
    on<ThemeToggleEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ThemeToggleEventSetLight>((event, emit) {
      try {
        emit(ThemeToggleStateIsLight());
      } catch (e) {
        emit(ThemeToggleStateError());
      }
    });

    on<ThemeToggleEventSetDark>((event, emit) {
      try {
        emit(ThemeToggleStateIsDark());
      } catch (e) {
        emit(ThemeToggleStateError());
      }
    });
  }
}
