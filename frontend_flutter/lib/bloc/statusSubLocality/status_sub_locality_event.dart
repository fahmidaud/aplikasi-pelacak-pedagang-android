part of 'status_sub_locality_bloc.dart';

@immutable
sealed class StatusSubLocalityEvent {}

class StatusSubLocalityEventSet extends StatusSubLocalityEvent {
  final bool isDragMapJelajah;
  final String subLocality;
  final bool isModeJelajah;

  StatusSubLocalityEventSet(
      {required this.isDragMapJelajah,
      required this.subLocality,
      required this.isModeJelajah});
}
