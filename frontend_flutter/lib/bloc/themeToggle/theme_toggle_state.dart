part of 'theme_toggle_bloc.dart';

@immutable
abstract class ThemeToggleState {}

// class ThemeToggleInitial extends ThemeToggleState {}

class ThemeToggleStateIsLight extends ThemeToggleState {}

class ThemeToggleStateIsDark extends ThemeToggleState {}

class ThemeToggleStateError extends ThemeToggleState {}
