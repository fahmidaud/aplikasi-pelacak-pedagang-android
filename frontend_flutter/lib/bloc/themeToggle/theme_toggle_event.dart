part of 'theme_toggle_bloc.dart';

@immutable
abstract class ThemeToggleEvent {}

class ThemeToggleEventSetLight extends ThemeToggleEvent {}

class ThemeToggleEventSetDark extends ThemeToggleEvent {}
