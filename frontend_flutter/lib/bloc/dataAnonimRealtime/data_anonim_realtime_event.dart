part of 'data_anonim_realtime_bloc.dart';

@immutable
sealed class DataAnonimRealtimeEvent {}

class DataAnonimRealtimeEventInitial extends DataAnonimRealtimeEvent {
  final bool isModeJelajah;
  final String subLocalityJelajah;

  DataAnonimRealtimeEventInitial(this.isModeJelajah, this.subLocalityJelajah);
}
