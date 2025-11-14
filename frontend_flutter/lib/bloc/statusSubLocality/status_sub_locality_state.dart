part of 'status_sub_locality_bloc.dart';

@immutable
sealed class StatusSubLocalityState {}

final class StatusSubLocalityInitial extends StatusSubLocalityState {}

class StatusSubLocalityStateShare extends StatusSubLocalityState {
  final bool isDragMapJelajah;
  final String subLocality;
  final bool isModeJelajah;

  StatusSubLocalityStateShare(
      this.isDragMapJelajah, this.subLocality, this.isModeJelajah);
}
