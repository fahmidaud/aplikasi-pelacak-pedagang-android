part of 'data_pembeli_realtime_bloc.dart';

@immutable
sealed class DataPembeliRealtimeEvent {}

class DataPembeliRealtimeEventInitial extends DataPembeliRealtimeEvent {
  final bool isModeJelajah;
  final String subLocalityJelajah;

  DataPembeliRealtimeEventInitial(this.isModeJelajah, this.subLocalityJelajah);
}
